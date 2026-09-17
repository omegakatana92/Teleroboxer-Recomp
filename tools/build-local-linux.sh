#!/usr/bin/env bash
# Build a local x86_64 Linux Teleroboxer runtime. Nothing it produces belongs
# in Git: the user's ROM, generated ROM-derived C, framework checkout, local
# CMake integration, and binary output are all ignored.
set -euo pipefail

usage() {
  printf 'Usage: %s /absolute/path/to/Teleroboxer.vb\n' "$0"
}

[[ $# -eq 1 ]] || { usage >&2; exit 2; }

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ROM_PATH="$(realpath -- "$1")"
FRAMEWORK_DIR="$PROJECT_DIR/vbrecomp"
PINNED_SHA="794a200f4001cb8314955794d2726ae1ea3f5123"
EXPECTED_SHA256="5bfdc99d6b5bdf32daf3c87e310aa078d6d51c733b02bbbf4042222578b60a36"
LOCAL_CMAKE="$PROJECT_DIR/CMakeLists.txt"

[[ -f "$ROM_PATH" ]] || { printf 'ROM file was not found: %s\n' "$ROM_PATH" >&2; exit 1; }
[[ "$(sha256sum -- "$ROM_PATH" | awk '{print $1}')" == "$EXPECTED_SHA256" ]] || {
  printf 'ROM hash does not match the supported Teleroboxer dump.\n' >&2
  exit 1
}

for command in git cmake ninja python3 pkg-config; do
  command -v "$command" >/dev/null 2>&1 || { printf 'Missing required command: %s\n' "$command" >&2; exit 1; }
done
pkg-config --exists sdl2 || { printf 'SDL2 development files are required.\n' >&2; exit 1; }

if [[ ! -d "$FRAMEWORK_DIR/.git" ]]; then
  git clone https://github.com/mstan/vbrecomp.git "$FRAMEWORK_DIR"
fi
git -C "$FRAMEWORK_DIR" fetch --quiet origin "$PINNED_SHA"
git -C "$FRAMEWORK_DIR" checkout --quiet --detach "$PINNED_SHA"

mkdir -p -- "$PROJECT_DIR/generated"
(
  cd -- "$FRAMEWORK_DIR"
  python3 -m recompiler.cli.vbrecomp_codegen \
    --rom "$ROM_PATH" \
    --module teleroboxer \
    --out "$PROJECT_DIR/generated" \
    --seeds-toml "$PROJECT_DIR/teleroboxer.toml"
)

if [[ ! -f "$LOCAL_CMAKE" ]]; then
  cat > "$LOCAL_CMAKE" <<'EOF'
cmake_minimum_required(VERSION 3.20)
project(TeleroboxerRecomp C CXX)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(VBRECOMP_GAME "teleroboxer" CACHE STRING "Generated vbrecomp module" FORCE)
set(VBRECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/vbrecomp" CACHE PATH "Local vbrecomp checkout")
if(NOT EXISTS "${VBRECOMP_ROOT}/CMakeLists.txt")
  message(FATAL_ERROR "Missing local vbrecomp checkout. Run tools/build-local-linux.sh first.")
endif()
add_subdirectory("${VBRECOMP_ROOT}" vbrecomp)
target_compile_definitions(vb-runtime PRIVATE
  VB_GAME_ID="teleroboxer"
  VB_GAME_TITLE="Teleroboxer Recomp"
  VB_GAME_SHA256="5bfdc99d6b5bdf32daf3c87e310aa078d6d51c733b02bbbf4042222578b60a36"
  VB_GAME_CRC32=0x36103000u)
set_target_properties(vb-runtime PROPERTIES OUTPUT_NAME TeleroboxerRecomp)
EOF
fi

cmake -S "$PROJECT_DIR" -B "$PROJECT_DIR/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DVBRECOMP_DEBUG_TOOLS=OFF
cmake --build "$PROJECT_DIR/build" --target vb-runtime

RUNTIME_PATH="$PROJECT_DIR/build/vbrecomp/runtime/TeleroboxerRecomp"
[[ -x "$RUNTIME_PATH" ]] || {
  printf 'Build completed but runtime was not found at %s\n' "$RUNTIME_PATH" >&2
  exit 1
}
printf '\nRuntime built successfully:\n%s\n' "$RUNTIME_PATH"

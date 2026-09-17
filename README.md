# Teleroboxer Recomp

A work-in-progress native recompilation project for **Teleroboxer** on the Nintendo Virtual Boy, built using **mstan's vbrecomp framework**.

> **Status: Experimental / Work in Progress**
>
> This repository contains only project-side configuration, documentation, and other non-copyrighted development material. It intentionally excludes ROMs, generated ROM-derived code, binaries, build outputs, runtime bundles, CMake project files, and copyrighted game assets.

## Credit

This project is powered by **vbrecomp**, created by **mstan**:

https://github.com/mstan/vbrecomp

vbrecomp provides the NEC V810 static recompiler, native runtime architecture, Virtual Boy hardware support, debugging infrastructure, and related tooling used by this project.

Please preserve this credit when redistributing or modifying this repository.

## What this project does

The goal is to statically translate the original Virtual Boy game's NEC V810 machine code into native code using vbrecomp while keeping the original cartridge program as the source of game behavior.

This project does **not** manually recreate Teleroboxer's game logic and does not distribute Nintendo game data.

## ROM requirement

**Teleroboxer is not included.**

You must provide your own legally obtained cartridge dump locally when developing or running the project.

Supported development ROM metadata:

| Property | Value |
| --- | --- |
| Game | Teleroboxer |
| Platform | Nintendo Virtual Boy |
| Size | 1,048,576 bytes |
| SHA-256 | `5bfdc99d6b5bdf32daf3c87e310aa078d6d51c733b02bbbf4042222578b60a36` |
| CRC32 | `0x36103000` |

A valid ROM may be renamed; validation should be based on its contents/hash rather than its filename.

## ROM selector goal

The intended user-facing startup flow is:

```text
Launch Teleroboxer executable
        ↓
No remembered ROM found
        ↓
Native ROM-selection popup
        ↓
User selects .vb file
        ↓
ROM is validated
        ↓
Valid ROM → runtime starts
Wrong ROM → selector is shown again
```

The ROM itself must remain on the user's computer. It must not be copied into this repository or bundled with a release.

## Included repository files

This public repository is intentionally kept minimal. Safe project-side material may include:

```text
.gitignore
.gitmodules
teleroboxer.toml
vbrecomp.pin
recomp-ui.pin
docs/
README.md
LICENSE / attribution files
```

## Intentionally excluded

Do **not** commit or publish any of the following:

```text
*.vb
*.rom
*.bin
*.cue
*.iso
*.exe
*.dll
*.o
*.obj
*.a
*.lib
*.pdb
*.zip

roms/
build/
build-*/
out/
generated/
release-stage/
captures/
beetle-vb/
vbrecomp/
recomp-ui/

CMakeLists.txt
*.cmake
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
Makefile
```

Also exclude:

- extracted sprites, textures, graphics, fonts, music, voices, or sound effects
- ROM-derived generated C/C++ or data tables
- copyrighted game resources of any kind
- packaged runtime files
- build artifacts or executables

The vbrecomp and recomp-ui projects should be obtained separately from their upstream repositories rather than vendored into this repository.

## Framework pin

The development project currently targets the vbrecomp framework. The exact tested revision is recorded in `vbrecomp.pin`.

Framework source:

https://github.com/mstan/vbrecomp

## Static analysis notes

Project analysis has identified the Teleroboxer reset vector, ROM metadata, V810 code coverage, and other bring-up information. See `docs/ANALYSIS.md` for development notes.

Analysis reports must contain only technical metadata and observations, never copied ROM data or extracted copyrighted assets.

## Development rules

This project follows vbrecomp's core design principles:

- no game-specific HLE replacements used to fake progress
- no fabricated frames, return values, interrupts, or game state
- do not manually patch generated code to hide recompiler bugs
- investigate decoder, recompiler, runtime, hardware, or configuration problems at their source
- validate real runtime behavior rather than treating a successful compile as proof of functionality

## Copyright and trademark notice

Teleroboxer and Nintendo Virtual Boy are properties of their respective rights holders.

This is an independent fan-made research and preservation project. It is not affiliated with, authorized by, sponsored by, or endorsed by Nintendo.

No Teleroboxer ROM, copyrighted game assets, executable release, or ROM-derived generated source is included in this repository.

## Credits

- **mstan** — creator of the vbrecomp Virtual Boy static recompilation framework
- **vbrecomp contributors** — framework development and Virtual Boy runtime/recompiler work
- Virtual Boy documentation, preservation, emulator, and reverse-engineering communities

vbrecomp:
https://github.com/mstan/vbrecomp

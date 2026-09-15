# TeleroboxerVirtualBoyRecomp

A work-in-progress native recompilation project for **Teleroboxer** on the Nintendo Virtual Boy, built using **mstan's vbrecomp framework**.

> **Status: Early Development / Experimental**
>
> Teleroboxer is currently being brought up as a new vbrecomp target. Native gameplay should not be considered functional until it has been tested and verified.

## Overview

TeleroboxerVirtualBoyRecomp aims to statically recompile the original game's **NEC V810 machine code into C**, which can then be compiled into a native executable for modern systems.

The general pipeline is:

```text
Teleroboxer Virtual Boy ROM
          ↓
     V810 machine code
          ↓
        vbrecomp
          ↓
      Generated C
          ↓
   Native compilation
          ↓
TeleroboxerVirtualBoyRecomp
```

This project does not manually recreate Teleroboxer's game logic and is not intended to simply wrap a conventional Virtual Boy emulator.

The original cartridge code remains the source of game behavior.

## Current Status

Development is currently focused on initial Teleroboxer support.

Planned milestones include:

* [ ] Verify the development ROM revision
* [ ] Record ROM CRC32 and SHA-256
* [ ] Analyze V810 code coverage
* [ ] Generate Teleroboxer C code successfully
* [ ] Build the native runtime
* [ ] Execute the game's reset/bootstrap code
* [ ] Initialize Virtual Boy hardware state
* [ ] Reach the title screen
* [ ] Verify controller input
* [ ] Verify graphics
* [ ] Verify audio
* [ ] Reach gameplay
* [ ] Complete a boxing match
* [ ] Compare runtime behavior against Beetle VB
* [ ] Investigate remaining accuracy issues
* [ ] Prepare the first playable release

This list will be updated as development progresses.

## vbrecomp

This project is powered by **vbrecomp**, created by **mstan**.

vbrecomp is a static recompilation framework for the NEC V810 CPU used by the Nintendo Virtual Boy.

It provides the major components required for a Virtual Boy recompilation project, including:

* V810 instruction decoding
* Static V810-to-C recompilation
* Native generated-code execution
* Interpreter fallback
* Virtual Boy memory handling
* VIP graphics support
* VSU audio support
* Interrupt and timer handling
* Input
* SDL frontend
* TCP debugging tools
* Beetle VB oracle comparison

Framework:

https://github.com/mstan/vbrecomp

Please support and credit the original vbrecomp project when using or modifying this project.

## ROM Requirement

**This repository does not contain Teleroboxer.**

You must provide your own legally obtained Nintendo Virtual Boy cartridge dump.

Place the supported ROM in:

```text
roms/teleroboxer.vb
```

The `roms/` directory is excluded from Git and must remain excluded.

### Supported ROM

The exact development ROM information will be documented after verification.

| Property        | Value                |
| --------------- | -------------------- |
| Game            | Teleroboxer          |
| Platform        | Nintendo Virtual Boy |
| Region/Revision | To be verified       |
| File size       | To be verified       |
| CRC32           | To be verified       |
| SHA-256         | To be verified       |

Do not assume that another ROM revision will work until it has been tested.

## Repository Layout

```text
TeleroboxerVirtualBoyRecomp/
├── CMakeLists.txt
├── README.md
├── LICENSE.md
├── .gitignore
├── teleroboxer.toml
├── vbrecomp.pin
│
├── generated/
│   └── V810 → C generated code
│
├── roms/
│   └── teleroboxer.vb
│
├── build/
│   └── local build output
│
└── vbrecomp/
    └── mstan's vbrecomp framework
```

The exact structure may evolve alongside the upstream vbrecomp framework.

## Requirements

The primary development environment is currently Windows.

Recommended requirements:

* Windows 10 or Windows 11
* Git
* Python 3.10+
* CMake
* Ninja
* MSYS2
* MinGW-w64 GCC/G++
* SDL2

A typical MSYS2 MinGW64 installation is located at:

```text
C:\msys64\mingw64\bin
```

## Clone

Clone the repository:

```powershell
git clone <TeleroboxerVirtualBoyRecomp repository URL>
cd TeleroboxerVirtualBoyRecomp
```

Initialize dependencies if the project uses vbrecomp as a Git submodule:

```powershell
git submodule update --init --recursive
```

## Add Your ROM

Copy your own Teleroboxer dump into:

```text
roms\teleroboxer.vb
```

For example:

```powershell
Copy-Item -LiteralPath "C:\Path\To\Your\Teleroboxer.vb" `
    -Destination ".\roms\teleroboxer.vb"
```

The ROM must never be added to Git.

## Verify the ROM

SHA-256 can be calculated with PowerShell:

```powershell
Get-FileHash ".\roms\teleroboxer.vb" -Algorithm SHA256
```

You can check its size with:

```powershell
Get-Item ".\roms\teleroboxer.vb" |
    Select-Object Name, Length
```

The verified hashes for the supported revision will be added to this README once established.

## Test vbrecomp

Before performing game-specific development, verify that the framework's tests pass.

From the appropriate vbrecomp directory:

```powershell
python -m unittest discover recompiler/tests
```

Framework failures should be investigated before continuing with Teleroboxer-specific debugging.

## Generate the Recompiled Code

Teleroboxer's generated C should be produced using the current vbrecomp code-generation tools.

The command will generally follow the form:

```powershell
python -m recompiler.cli.vbrecomp_codegen `
    --rom "<path-to-teleroboxer.vb>" `
    --module teleroboxer `
    --out "<generated-directory>" `
    --seeds-toml "<teleroboxer.toml>"
```

Check the version of vbrecomp pinned by this repository before relying on this example, as the CLI may change during development.

### Important

**Do not manually repair generated C.**

If generated code is incorrect, fix the appropriate recompiler, configuration, discovery, runtime, or hardware-model problem and regenerate the output.

## Build

The exact build command depends on the version of vbrecomp pinned by this repository.

A typical Windows MinGW/Ninja configuration resembles:

```powershell
$env:PATH = "C:\msys64\mingw64\bin;$env:PATH"

cmake -S . -B build -G Ninja `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_MAKE_PROGRAM=C:/msys64/mingw64/bin/ninja.exe `
    -DCMAKE_C_COMPILER=C:/msys64/mingw64/bin/gcc.exe `
    -DCMAKE_CXX_COMPILER=C:/msys64/mingw64/bin/g++.exe

cmake --build build
```

Do not assume a successful compilation means the game is working correctly. Runtime behavior must also be validated.

## Running

Once a working native target has been established, the executable will require the user's Teleroboxer ROM.

The expected invocation will resemble:

```powershell
.\TeleroboxerVirtualBoyRecomp.exe --rom ".\roms\teleroboxer.vb"
```

The final executable location and command will be documented once the initial native build is operational.

## Debugging

vbrecomp provides a TCP-based debugging system.

Typical development ports are:

```text
4390    Native vbrecomp runtime
4391    Beetle VB reference/oracle
```

Development should use the framework's existing debugging infrastructure instead of adding large printf-based trace logs.

Useful comparisons can include:

* CPU registers
* memory
* function execution
* memory writes
* interpreter fallback
* VIP state
* framebuffer output
* interrupts
* timers
* input
* audio behavior

## Beetle VB Reference

During development, an independent Beetle VB process can be used as an execution reference.

This allows behavior from the native recompilation to be compared against an established Virtual Boy implementation.

The reference environment is intended for development and debugging. It is not a replacement for the generated native code.

## Development Rules

The project follows several important principles inherited from vbrecomp:

**No game-specific HLE replacements.**

Do not manually recreate a Teleroboxer function simply to make the game progress.

**No fake results.**

Do not fabricate frames, register values, return values, interrupts, or other game behavior.

**Do not modify generated code to hide recompiler bugs.**

Fix the source of the problem and regenerate.

**Unknown is better than guessing.**

If an instruction, function, indirect branch, MMIO interaction, or hardware behavior is not understood, document and investigate it.

**Validate visible progress.**

Compiling successfully is only one milestone. The actual game must execute correctly.

## Git / Copyright Safety

Before committing or pushing changes, verify that the repository does not contain:

```text
*.vb
*.rom
*.bin
*.iso
*.cue
*.exe
build/
roms/
```

Additional generated or extracted copyrighted game data should also be excluded where appropriate.

Never commit the user's original cartridge dump.

## Releases

Future releases may contain the native recompilation executable and legally distributable supporting files.

They will **not** contain the Teleroboxer ROM.

Users will be required to provide their own supported cartridge dump.

## Credits

### Teleroboxer

Original game developed and published by Nintendo for the Nintendo Virtual Boy.

### vbrecomp

Created by **mstan**.

https://github.com/mstan/vbrecomp

The V810 static recompiler, Virtual Boy runtime, debugging infrastructure and related tooling originate from the vbrecomp project.

Additional credit belongs to the Virtual Boy preservation, reverse-engineering, documentation and emulator-development communities whose work has helped document the hardware.

## Disclaimer

TeleroboxerVirtualBoyRecomp is an independent fan-made research and preservation project.

It is not affiliated with, authorized by, sponsored by, or endorsed by Nintendo.

**Teleroboxer**, **Virtual Boy**, and related trademarks and copyrighted materials belong to their respective owners.

No game ROM is provided by this repository.

## Project Goal

The immediate milestone is:

**Boot Teleroboxer through generated native V810 → C code and reach the title screen.**

The larger goal is:

**Play and complete a Teleroboxer boxing match with working graphics, controls and audio through the native recompilation runtime.**

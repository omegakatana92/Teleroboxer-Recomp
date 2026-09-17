# Teleroboxer — Static Analysis Notes

These notes contain technical metadata and analysis results only. They do not contain ROM data or extracted copyrighted assets.

Framework: vbrecomp @ `794a200f4001cb8314955794d2726ae1ea3f5123`

## ROM metadata

| Field | Value |
| --- | --- |
| Title | TELEROBOXER |
| Maker code | 01 (Nintendo) |
| Game code | VTBJ |
| Version | 0x00 |
| Size | 1,048,576 bytes (1 MB / 8 Mbit) |
| SHA-256 | `5bfdc99d6b5bdf32daf3c87e310aa078d6d51c733b02bbbf4042222578b60a36` |
| CRC32 | `0x36103000` |

## Reset and entry

The Virtual Boy reset PC is `0xFFFFFFF0`. Analysis indicates that Teleroboxer's reset trampoline transfers control to the cart entry at `0xFFF67F0A`.

## CFG-aware discovery

Analysis using vbrecomp's control-flow-aware discovery reported:

| Metric | Value |
| --- | ---: |
| Entry PC | `0xFFF67F0A` |
| Functions discovered | 4,542 |
| Instructions visited | 105,400 |
| Unknown reachable instructions | 0 |
| Call sites | 1,555 |
| Unresolved indirect jumps | 0 |

The reachable-code analysis is the useful metric for bring-up; linear scanning of the full ROM also encounters data regions that may resemble instructions.

## Memory map notes

The 1 MB cartridge image maps through the Virtual Boy cartridge ROM region. Development should preserve vbrecomp's normal address mirroring and Virtual Boy MMIO behavior rather than adding game-specific shortcuts.

Relevant regions include:

- VIP / video memory and registers
- WRAM
- cartridge ROM

## Bring-up priorities

1. Verify ROM hash at runtime.
2. Confirm reset/bootstrap reaches the cart entry.
3. Verify the runtime debug endpoint responds.
4. Compare execution and video behavior against the independent Virtual Boy reference/oracle workflow supported by vbrecomp.
5. Investigate any divergence in the recompiler, runtime, hardware model, timing, or per-cart configuration rather than patching generated output.

## Publication policy

Do not add generated ROM-derived C, extracted graphics, audio, ROM bytes, binaries, build artifacts, runtime bundles, or other copyrighted game content to this repository.

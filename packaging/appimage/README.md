# Steam Deck AppImage packaging

This directory packages a separately built Teleroboxer Linux runtime. It does
not download, contain, or distribute the game ROM, generated ROM-derived code,
or copyrighted game assets.

## Requirements

- x86_64 Linux runtime built from the vbrecomp-based project
- `linuxdeploy` and `appimagetool` (x86_64 Linux builds)
- `file`, `realpath`, and `sha256sum`
- Zenity (available in SteamOS Desktop Mode) or KDialog for the ROM picker

The runtime must accept a ROM using vbrecomp's `--rom <path>` interface. This
is the contract between `AppRun` and the native runtime.

## Build

```bash
packaging/appimage/build-appimage.sh /path/to/teleroboxer-runtime
```

If either packaging tool is not on `PATH`, set it explicitly:

```bash
LINUXDEPLOY=/path/to/linuxdeploy APPIMAGETOOL=/path/to/appimagetool \\
  packaging/appimage/build-appimage.sh /path/to/teleroboxer-runtime
```

Output: `packaging/appimage/dist/Teleroboxer-Recomp-x86_64.AppImage`

`linuxdeploy` collects the runtime's shared-library dependencies before
`appimagetool` creates the final file. Do not package a ROM alongside it.

## Steam Deck use

1. Copy the AppImage and your legally obtained `.vb` dump to the Steam Deck.
2. In Desktop Mode, make the AppImage executable in its file properties.
3. Launch it and select the ROM when prompted.
4. In Steam, choose **Add a Non-Steam Game**, browse to the AppImage, and add it.
5. Return to Gaming Mode and launch it from the Non-Steam library.

The selected ROM path is saved under the user's XDG configuration directory.
Pass `--rom /path/to/game.vb` to replace it. The ROM is validated by SHA-256
and is never copied into the AppImage.

The runtime's settings, saves, and optional mod packages are stored in the
user's XDG data directory, not inside the read-only AppImage mount.

# Rayburst — Inno Setup distribution build

This repository replaces the earlier incomplete Avalonia prototype with a reproducible Windows installer build around the **actual Rayburst 4.1.0 application source**. The `upstream` Git submodule is pinned to the signed upstream `v4.1.0` release commit `e8173d6d5b47576309e434150192b2a1649a4110`.

- Upstream application: https://github.com/AnInsomniacy/rayburst
- Pinned release: https://github.com/AnInsomniacy/rayburst/releases/tag/v4.1.0
- Pinned commit: `e8173d6d5b47576309e434150192b2a1649a4110`

The original Vue 3 + TypeScript + Tauri 2 + Rust application and its architecture-matched aria2-next engine are preserved rather than approximated with a partial rewrite. That keeps upstream behavior such as HTTP/SFTP/ED2K/BitTorrent downloads, HLS/DASH capture, browser handoff, torrent controls, persistence, preferences, localization, themes, and tray integration.

## Installer outputs

A successful GitHub Actions run uploads two independent Inno Setup installers:

- `Rayburst-4.1.0-Setup-x64.exe` — Windows x86-64
- `Rayburst-4.1.0-Setup-arm64.exe` — Windows ARM64

The workflow builds the pinned upstream source for each architecture, prepares the runtime payload, compiles it using Inno Setup 6, and fails if either setup file is missing. The installer includes Rayburst's browser native-messaging manifests and registers the host, torrent-open candidate, and protocol candidates without silently changing the user's default handlers.

## Run the build locally

Requirements: Windows 11, Git with submodule support, Node.js 24, pnpm 11.5.2, Rust stable, Visual Studio C++ Build Tools (including ARM64 components for the ARM64 target), and Inno Setup 6.

```powershell
git clone --recurse-submodules https://github.com/PCUser2021/RayburstAvalonia.git
cd RayburstAvalonia
$env:TARGET_TRIPLE = "x86_64-pc-windows-msvc"
$env:OUTPUT_ARCH = "x64"
$env:RAYBURST_VERSION = "4.1.0"
.\scripts\Build-Rayburst.ps1
```

To build ARM64, set `TARGET_TRIPLE` to `aarch64-pc-windows-msvc` and `OUTPUT_ARCH` to `arm64`.

## Attribution

This repository is an **unofficial packaging project**, not the official Rayburst project. The pinned application source is from AnInsomniacy and retains its MIT license; see [LICENSE](LICENSE). Third-party project notes, including why OnionFruit's unrelated Tor/.NET runtime is not injected into Rayburst's Tauri download engine, are in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

# Rayburst — Avalonia port (work in progress)

> **Status correction (2026-10-23): the published v0.1.0 build is only a basic prototype. It is not a 100% recreation of Rayburst. Do not treat the current release as feature-complete.**

The target is to port the behavior and feature set of [Rayburst](https://github.com/AnInsomniacy/rayburst) to a Windows-first .NET 10 / Avalonia application, using the [OnionFruit 2026.620.0 source](https://github.com/dragonfruitnetwork/onionfruit/tree/2026.620.0) as the requested UI/application-architecture reference. This project must not use ResolverReach as its foundation.

**Important distinction:** OnionFruit is a Tor proxy gateway, not a download manager. Its [installer](https://github.com/dragonfruitnetwork/onionfruit/releases/download/2026.620.0/install-x64.exe) is a compiled binary; the [source archive](https://github.com/dragonfruitnetwork/onionfruit/archive/refs/tags/2026.620.0.zip) is the relevant reference for its .NET 10, Avalonia, FluentAvalonia and ReactiveUI architecture. The Tor-specific behavior must be replaced with Rayburst's download-manager behavior.

## Target features

The target includes Rayburst's multi-protocol download engine and task experience, HLS/DASH handling, torrent and magnet flows, browser extension handoff, task scheduling/speed limits, history, tray/lightweight/floating-window behavior, notifications, system integration, settings, localization, and updater. The detailed acceptance checklist is in [PORT_SPECIFICATION.md](PORT_SPECIFICATION.md).

- Target behavior source: [Rayburst](https://github.com/AnInsomniacy/rayburst)
- Requested architecture reference: [OnionFruit 2026.620.0](https://github.com/dragonfruitnetwork/onionfruit/tree/2026.620.0)
- Download engine to evaluate/pin: [Aria2 Next 3.0.8](https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.8)

## Current build

The existing `RayburstReach` prototype has a basic Avalonia window and local Aria2 Next JSON-RPC task controls. The x64 and ARM64 installers compiled successfully in GitHub Actions, but only compile/package success was verified. Runtime smoke tests and feature parity have not been established.

[View published v0.1.0 artifacts](https://github.com/PCUser2021/RayburstAvalonia/releases/tag/v0.1.0) — **prototype only, not feature-complete**.

## Licensing

Rayburst's source is MIT-licensed. OnionFruit is LGPL-3.0-licensed. Aria2 Next carries its own upstream license. If code is incorporated from OnionFruit or bundled from Aria2 Next, preserve the corresponding source, copyright, license, and distribution obligations. See [LICENSE](LICENSE) and [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

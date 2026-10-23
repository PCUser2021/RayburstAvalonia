# Rayburst port specification

## Correct source selection

This project must use the **OnionFruit 2026.620.0 source archive** as the Avalonia/.NET application-shell and UI-architecture reference, not ResolverReach. The reference tag is:

- Source: https://github.com/dragonfruitnetwork/onionfruit/tree/2026.620.0
- Source archive: https://github.com/dragonfruitnetwork/onionfruit/archive/refs/tags/2026.620.0.zip
- Reference installer (Windows x64): https://github.com/dragonfruitnetwork/onionfruit/releases/download/2026.620.0/install-x64.exe

OnionFruit is a Tor proxy gateway, not a download manager. Its installer is a compiled program, not a library or source input. The source archive is the useful reference. OnionFruit is .NET 10 / Avalonia / FluentAvalonia / ReactiveUI and is licensed under LGPL-3.0; its license and notices must be respected if code is incorporated.

The target feature specification remains the original Rayburst project:

- Source of behavior/features: https://github.com/AnInsomniacy/rayburst
- Rayburst license: MIT
- Engine release to evaluate and pin: https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.8

## Acceptance target

A port is **not feature-complete** until the relevant behavior has been implemented and tested. A successful .NET build or installer compile alone does not meet this target.

### Download engine and tasks
- [ ] Bundle architecture-matched Aria2 Next binaries and verify their published SHA-256 checksums.
- [ ] HTTP, HTTPS, FTP/SFTP where provided by the engine, ED2K, BitTorrent, magnets, and .torrent workflows.
- [ ] HLS/DASH workflows: tracks, subtitles, live capture/recording, resume, and output handling.
- [ ] Add/confirm window with resolved filename, size, destination, disk-space information, source/redirect details, and torrent file selection.
- [ ] Concurrent tasks, queueing, pause/resume, retry/recovery, connection limits, per-task and global speed limits.
- [ ] Task detail, selected torrent files, metadata, move unfinished download, safe filename/path handling and collision avoidance.
- [ ] Completion/failure actions, notifications, keep-awake and shutdown-after-completion options.

### UI and desktop integration
- [ ] Recreate Rayburst's main layout, navigation, task list, add-task dialog, details, preferences and animated interactions in Avalonia.
- [ ] Light/dark/system themes, color schemes, localization, keyboard/clipboard/drag-and-drop behavior.
- [ ] Tray, lightweight mode, floating progress window, launch at login, single-instance handling and protocol/file associations.
- [ ] Browser extension/native messaging and local Extension API, authentication, hand-off confirmation, referer/cookie forwarding and controls.
- [ ] Settings persistence, SQLite history, completed-record policy and exportable diagnostic logs.
- [ ] Updater channels and safe release install/update behavior.

### Build and quality gates
- [ ] Windows x64 and native ARM64 self-contained builds.
- [ ] Architecture-matched engine in each installer.
- [ ] Installer install/uninstall smoke tests on both architectures.
- [ ] Integration tests for task lifecycle, engine startup/RPC authentication, protocols, and path safety.
- [ ] Release checksum manifest and required third-party license notices.
- [ ] Compare each implemented item against the Rayburst source behavior before marking it complete.

## Current prototype status

The initial `RayburstReach` v0.1.0 prototype is **not** a 100% recreation of Rayburst and must not be represented as one. It has only a basic Avalonia window and JSON-RPC task controls. The first published installer run verified compilation and packaging only; it did not verify runtime behavior or the acceptance checklist above.

This file exists to make scope and completion status explicit and prevent a working installer from being confused with feature parity.

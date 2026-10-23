# Rayburst recreation checklist

Target: full feature and UI recreation of https://github.com/AnInsomniacy/rayburst using the Windows application structure from OnionFruit tag 2026.620.0:
https://github.com/dragonfruitnetwork/onionfruit/tree/2026.620.0

Windows startup remains:

    dotnet run --project DragonFruit.OnionFruit.Windows

Apply the overlay from scripts/Apply-RayburstPort.ps1 to the cloned OnionFruit source first. The unmodified OnionFruit checkout remains a Tor gateway, not Rayburst.

## Implemented in current overlay
- [x] Avalonia download queue window.
- [x] Basic Aria2 Next subprocess, local JSON-RPC and random RPC secret.
- [x] Basic HTTP(S), FTP/SFTP, magnet and ED2K link submission.
- [x] Folder picker, progress/status/speed, pause/resume/remove/refresh.

## Required for the 100% recreation
- [ ] Match all Rayburst windows, layouts, interaction states, menus, keyboard behavior and visual details.
- [ ] Full HTTP/HTTPS/FTP/SFTP/ED2K/BitTorrent/magnet/.torrent task and option flows.
- [ ] Torrent metadata, file selection, trackers, DHT/PEX, encryption, GeoIP and tracker probing.
- [ ] HLS/DASH: tracks, subtitles, live recording, resume and MP4/MKV output.
- [ ] Browser extension/native messaging, extension API, cookies/referer forwarding and confirmation flows.
- [ ] Queue semantics, retry/recovery, concurrency, global/per-task speed controls and schedules.
- [ ] Persistent task/history database, favorite/recent folders, safe filenames and collision handling.
- [ ] Task details, diagnostics, log export, database checks and error recovery.
- [ ] Tray, lightweight/floating windows, startup behavior, deep links and file associations.
- [ ] Notifications, keep-awake/shutdown actions, proxy settings and updater channels.
- [ ] Themes, colors, localization, accessibility, clipboard/drag-and-drop and shortcuts.
- [ ] Unit/integration tests for lifecycle, RPC, protocols, filesystem safety and upgrades.
- [ ] Successful Windows x64 and ARM64 builds, installer/uninstaller smoke tests, and stable production packaging.

A successful compile does not prove feature parity. Do not call the port complete until each remaining item is implemented and validated.

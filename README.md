# Rayburst Avalonia — OnionFruit-based port in progress

The target is a **complete recreation of [Rayburst](https://github.com/AnInsomniacy/rayburst)**, using the Windows .NET 10/Avalonia project structure from [OnionFruit](https://github.com/dragonfruitnetwork/onionfruit) as the starting point.

**Current truth:** this is not 100% complete yet. The repository contains a Rayburst UI/engine overlay and a script that applies it to the OnionFruit source checkout. Feature gaps are listed in PORT_SPECIFICATION.md; I will not label the project complete before those are implemented and tested.

## Windows developer workflow

The port follows OnionFruit's Windows workflow: clone the source, enter its folder, and run the same Windows project. Because unmodified OnionFruit is a Tor proxy gateway, apply the Rayburst overlay before running it:

```powershell
git clone https://github.com/dragonfruitnetwork/onionfruit
cd onionfruit
git clone https://github.com/PCUser2021/RayburstAvalonia rayburst-port
.\rayburst-port\scripts\Apply-RayburstPort.ps1 -SourceRoot .
dotnet run --project DragonFruit.OnionFruit.Windows
```

Install Git and the .NET 10 SDK first. The overlay copies the Rayburst Avalonia window and download-engine client into the cloned source and changes the startup path so OnionFruit's Tor/proxy/DNS runtime is not started.

## Currently implemented

- Avalonia desktop window with URL entry and download queue.
- Destination folder picker.
- Basic task status/progress/speed display.
- Pause, resume, remove and refresh controls.
- Separate Aria2 Next engine process with JSON-RPC bound to loopback and a generated per-run secret.
- Windows CI configured to clone the pinned OnionFruit 2026.620.0 source, apply the overlay, and build x64/ARM64 packages.

## Not yet complete

Full Rayburst recreation still requires visual/interaction parity, comprehensive torrent controls and file selection, HLS/DASH workflows, browser extension/native messaging, cookies/referers, task details, scheduling and speed policies, persistent history, tray/lightweight/floating-window modes, protocol/deep-link and file associations, notifications and keep-awake behavior, proxy configuration, update channels, localization, and automated tests. A successful compile alone does not establish 100% parity.

## Licensing

Rayburst is MIT-licensed. OnionFruit source is LGPL-3.0; preserve its notices and comply with source/binary distribution requirements when distributing a derivative. Aria2 Next is a separately executed engine under its own upstream license. This is an independent port, not an official release from either project.

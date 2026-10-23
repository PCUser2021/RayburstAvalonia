# Rayburst Avalonia

A C# / .NET 10 / Avalonia Windows download-manager port scaffold, using the separately executed Aria2 Next engine. Its desktop architecture follows patterns from [ResolverReach](https://github.com/PCUser2021/ResolverReach), and the target behavior is informed by [Rayburst](https://github.com/AnInsomniacy/rayburst).

> **Status: early MVP scaffold, not feature-complete.** It includes a basic multi-download UI, task controls through the local Aria2 Next JSON-RPC interface, and CI configuration for Windows x64 and native ARM64 installers. It does not yet implement all Rayburst features.

## Installers

GitHub Actions is configured to build `RayburstReach-Setup-x64.exe` and `RayburstReach-Setup-arm64.exe`. These are created by CI; prebuilt installers are not committed to source control.

## Build

Requires the .NET 10 SDK and Windows for Inno Setup packaging.

```powershell
dotnet restore src/RayburstReach/RayburstReach.csproj
dotnet run --project src/RayburstReach/RayburstReach.csproj
```

The release workflow downloads the pinned Aria2 Next engine and verifies the upstream SHA-256 checksum before packaging it. The engine RPC listener is intended to bind to loopback only, with a generated per-run secret. Do not expose it to a network interface without a separately reviewed authentication and network-security design.

## License and attribution

Original application code: MIT; see [LICENSE](LICENSE). Rayburst and ResolverReach are separate MIT-licensed upstream projects. Aria2 Next is distributed under its upstream license; see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) and the Aria2 Next repository. This is an independent project and is not an official Rayburst release.

## Roadmap

- Persisted preferences, download history, queue scheduling, retries, concurrency controls.
- Task details, file selection, torrent file picker, and advanced per-download options.
- Browser integration, protocols/file associations, updater, tray behavior, localization, and import/export.
- Automated tests across HTTP, FTP, BitTorrent, magnet, and ED2K flows.

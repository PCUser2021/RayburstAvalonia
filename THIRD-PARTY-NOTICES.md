# Third-party notices

## Rayburst

The application source, branding, and application assets are from [AnInsomniacy/rayburst](https://github.com/AnInsomniacy/rayburst), pinned to release `v4.1.0` (commit `e8173d6d5b47576309e434150192b2a1649a4110`). Rayburst is licensed under the MIT License; see `LICENSE`.

## aria2-next

Rayburst bundles the architecture-matched `aria2-next` executable supplied by the pinned Rayburst source tree. The upstream project's published licensing and source terms apply. The source project is maintained at https://github.com/AnInsomniacy/aria2-next.

## OnionFruit

[DragonFruit.Network/OnionFruit](https://github.com/dragonfruitnetwork/onionfruit) was inspected as the requested reference project. It is a separate Tor connectivity application distributed under LGPL-3.0, with a .NET/Avalonia stack; Rayburst is a Tauri/Rust + Vue download manager with its own aria2-next engine. Directly substituting OnionFruit's runtime or its Tor-specific code would not preserve Rayburst's behavior. Accordingly, this distribution keeps the real upstream Rayburst implementation intact and does not falsely claim to embed OnionFruit code. If OnionFruit source code is later incorporated into the application, its LGPL notices and corresponding-source obligations must be satisfied.

## Inno Setup

Installers are compiled using Inno Setup 6. Inno Setup is not bundled into the application; see https://jrsoftware.org/isinfo.php for its license.

# DarkRP for Nanos World

An open-source, work-in-progress reimagining of Garry's Mod **DarkRP**, built for **Nanos World**.

The project focuses on a clean, modular foundation for building and extending a roleplay gamemode.

## Current Features

- Persistent player profiles using SQLite (RP name, wallet and salary data)
- Player spawning, character appearance and respawning
- Chat commands, including `/rpname`
- Optional modules for character customization and sandbox controls
- Package hot reload with player position and character mesh restoration

## Project Structure

```text
Client/              Client-side entry points
Server/
  Init.lua           Package lifecycle entry point
  Bootstrap.lua      Core setup and dependency wiring
  Core/
    Database/        Database access
    Player/          Player profiles and lifecycle
    Character/       Character spawning, appearance and lifecycle
  Modules/
    ModuleLoader.lua Optional module initialization and shutdown
    Registry.lua     Available modules
    ChatCommands/    RP chat commands
    CharacterCustomization/
    SandboxControls/
Shared/              Shared namespace, configuration and utilities
Package.toml         Nanos World package settings
```

The **Core** contains essential gamemode systems. **Modules** provide optional features that can be enabled or disabled in `Shared/Config.lua`. The bootstrap assembles the Core, while the module loader handles optional modules.

## Installation

Place the `darkrp` package in your Nanos World `Packages` directory, then start a server with the `darkrp` gamemode.

Configure the gamemode and its modules in `Shared/Config.lua`.

## Status

The architecture and initial player systems are in place. Jobs, properties, economy gameplay and the full RP interface are planned for future development.

## Contributing

The project is still in early development.

Feel free to fork it, suggest improvements, or use it as a base for your own RP ideas.

Made with ❤️ by **TheObtey**

Discord tag: `theobtey`
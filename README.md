# DarkRP for Nanos World

A modern reimagining of the classic Garry's Mod **DarkRP** gamemode, built from scratch for **Nanos World**.

This gamemode aims to bring full roleplay mechanics, modular systems, and a clean architecture to Nanos World.

---

## 🚀 Features (WIP)

- Persistent player data (RP name, money)
- RP name system via chat command (`/setrpname`)
- Clean UI integration planned (WebUI HUD)
- SQLite database integration (no external DB required)
- Modular architecture

---

## 🧠 Project Structure

```
darkrp/
├── Client/
│ ├── modules/ # Client-side systems (HUD, menus, etc.)
│ ├── Init.lua # Client-side entry point
│ └── Index.lua
├── Server/
│ ├── modules/ # Server-side modules (players, jobs, printers, etc.)
│ ├── Init.lua # Server-side setup (DB, loading, etc.)
│ └── Index.lua
├── Shared/
│ ├── Core.lua # Global DarkRP namespace
│ └── Utils.lua # Utility functions
├── UI/
│ └── MainHUD.html # HUD (planned)
└── Package.toml # Gamemode metadata
```

---

## ⚙️ Dependencies

None for now — fully standalone.

---

## 📦 Installation

1. Clone or download this repository into your Nanos World `Packages` folder.
2. Start a new server and select **"darkrp"** as your gamemode.
3. Everything loads automatically. Have fun!

---

## 📚 To-Do

- [ ] Job system
- [ ] Salary system
- [ ] Property ownership
- [ ] Printers & spawnable entities
- [ ] Voting / mayor system
- [ ] Full HUD integration

---

## 💡 Contributions

This project is in early development. Feel free to fork it, suggest improvements, or use it as a base for your own RP ideas.

---

## 👑 Author

Made with ❤️ by **TheObtey** 🫡  
Discord tag: `theobtey`
# TDS Macro Studio

A configurable AutoHotkey v2 desktop macro for repeating keyboard actions. The project keeps its original timed-key workflow and adds per-ability enable toggles, profile save/load, duplicate-key warnings, and a roomier dark interface.

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## Run

1. Download `TDS-Ability-Macro.ahk`.
2. Double-click it to open **TDS Macro Studio**.
3. Set each ability's key or SendInput sequence, interval, and time unit.
4. Leave **On** checked for abilities you want active.
5. Click **Start All**. Click **Stop All** or press **F6** to stop/restart the macro.
6. Use **Save Profile** and **Load Profile** to store and restore loadouts in INI files.

## Features

- Up to 8 independent ability rows.
- Custom key input, symbols, and SendInput sequences such as `{F1}`.
- Seconds (0.1–3600) or milliseconds (10–3,600,000).
- Enable or disable each row without removing it.
- Duplicate-key warning before starting.
- Save/load profiles, including keys, intervals, units, and enabled state.
- Add/remove abilities and scroll the list with the mouse wheel or Up/Down buttons.
- Live running status and total key-press counter.
- **F6** toggles start/stop; **F8** exits.

## Notes

Keyboard input is sent to whichever window is active when a timer fires, so focus the intended application before starting. Very short intervals are subject to Windows and AutoHotkey scheduling. Test with a harmless key first and use automation only where allowed by the game and platform rules.

The interface uses native AutoHotkey controls. This release is a first dashboard/profile pass; it has not been runtime-tested on your Windows machine yet, so please test starting/stopping and profile save/load before relying on it.

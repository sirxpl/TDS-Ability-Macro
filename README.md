# TDS Macro Studio

A configurable AutoHotkey v2 desktop macro for repeating keyboard actions. The project keeps its original timed-key workflow and adds per-ability enable toggles, profile save/load, duplicate-key warnings, and a roomier dark interface.

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## Run

1. Download the repository as a ZIP and extract the entire folder (keep the `src` folder beside the launcher).
2. Double-click `TDS-Ability-Macro.ahk` to open **TDS Macro Studio**.
3. Set each ability's key or SendInput sequence, interval, and time unit. Enable **Hold** if you want that physical key to repeat only while held.
4. Leave **On** checked for abilities you want active.
5. Click **Start All**. Click **Stop All** or press **F6** to stop/restart the macro.
6. Use **Save Profile** and **Load Profile** to store and restore loadouts in the automatically created `profiles` folder.

## Project layout

- `TDS-Ability-Macro.ahk` — launcher and dashboard setup.
- `src/FieldUI.ahk` — ability rows, layout, and scrolling.
- `src/MacroEngine.ahk` — timer scheduling, key validation, and key dispatch.
- `src/Profiles.ahk` — INI profile save/load.
- `profiles/` — created automatically when saving or loading profiles.

Keep the launcher and `src` folder together; the launcher includes the module files at startup.

## Features

- Up to 8 independent ability rows.
- Custom key input, symbols, and SendInput sequences such as `{F1}`.
- Seconds (0.1–3600) or milliseconds (10–3,600,000).
- Enable or disable each row without removing it.
- Per-row **Hold** mode repeats a supported key at its interval only while that physical key is held; releasing it stops repeats. Hold mode supports letters, numbers, F1–F12, Space, Enter, Tab, Escape, Backspace, Delete, Insert, Home/End, Page Up/Down, and arrow keys. Shifted symbols and SendInput sequences are not supported as Hold triggers.
- Profile save/load preserves the Hold setting; older profiles default to Hold off.
- Duplicate-key warning before starting.
- Save/load profiles, including keys, intervals, units, and enabled state.
- Add/remove abilities and scroll the list with the mouse wheel or Up/Down buttons.
- Live running status and total key-press counter.
- **F6** toggles start/stop; **F8** exits.

## Notes

Keyboard input is sent to whichever window is active when a timer fires, so focus the intended application before starting. Very short intervals are subject to Windows and AutoHotkey scheduling. Test with a harmless key first and use automation only where allowed by the game and platform rules.

The interface uses native AutoHotkey controls. This release is a first dashboard/profile pass; it has not been runtime-tested on your Windows machine yet, so please test starting/stopping and profile save/load before relying on it.

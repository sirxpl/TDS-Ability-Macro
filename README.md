# TDS Macro Studio

A configurable AutoHotkey v2 desktop macro with separate sections for timed abilities and hold-to-spam keys.

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## Run

1. Download the repository ZIP and extract the entire folder, keeping the `src` folder beside the launcher.
2. Double-click `TDS-Ability-Macro.ahk`.
3. Use the **Timed Abilities** tab for keys that repeat automatically on a schedule.
4. Use **Hold-to-Spam Keys** for keys that repeat only while you physically hold the configured key; releasing the key stops repeats.
5. Select a tab and use **Add to Section** to add a row to that section.
6. Use **Start All**, **Stop All**, or **F6** to control enabled rows. **F8** exits.
7. Use **Save Profile** and **Load Profile** to store both sections in the automatically created `profiles` folder.

## Project layout

- `TDS-Ability-Macro.ahk` — launcher and dashboard tabs.
- `src/FieldUI.ahk` — row controls and independent scrolling for each tab.
- `src/MacroEngine.ahk` — scheduling, validation, and key dispatch.
- `src/Profiles.ahk` — INI profile save/load for both sections.
- `profiles/` — created automatically when saving or loading profiles.

## Features

- Separate **Timed Abilities** and **Hold-to-Spam Keys** sections.
- Up to 8 rows in each section.
- Timed rows support custom keys, symbols, and SendInput sequences such as `{F1}`.
- Hold rows support letters, numbers, F1-F12, Space, Enter, Tab, Escape, Backspace, Delete, Insert, Home/End, Page Up/Down, and arrow keys.
- Intervals in seconds (0.1-3600) or milliseconds (10-3,600,000).
- Per-row enable toggles, add/remove controls, and independent scrolling.
- Profile save/load stores both sections and can import profiles from the previous single-list version.
- Live status and total key-press counter.
- **F6** toggles start/stop; **F8** exits.

## Notes

Keyboard input is sent to whichever window is active when a timer fires, so focus the intended application before starting. Very short intervals are subject to Windows and AutoHotkey scheduling. Test with a harmless key first and use automation only where allowed by the game and platform rules.

The interface uses native AutoHotkey controls. This redesign has not been runtime-tested on your Windows machine yet.

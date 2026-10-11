# TDS Ability Macro

A small AutoHotkey v2 project for prototyping timed keyboard actions.

## GUI: configurable repeating key

1. Install **AutoHotkey v2**.
2. Open [`TDS-Ability-Macro.ahk`](TDS-Ability-Macro.ahk) and download it.
3. Double-click the file to launch the desktop window.
4. Set **Interval (seconds)** to a number from **0.1 to 3600** (decimals are supported, e.g. `0.5`).
5. Set **Key to repeat** to one key: A-Z, 0-9, F1-F12, Space, Enter, or Tab.
6. Click **Start**. The selected key is sent at each interval.
7. Click **Stop** or press **F6** to stop/start. Press **F8** to exit.

The window displays the running status, number of key presses, and last press time. After starting, focus the intended application before the first press. The macro sends input to whichever window is active when the timer fires, so double-check the focused window.

## Notes

- This prototype repeats one key only; it does not click the mouse or support key combinations.
- Keep the stop shortcut handy and test with a harmless key first.
- Use automation only where allowed by the game and platform rules.

# TDS Ability Macro

A small AutoHotkey v2 project for prototyping timed keyboard actions.

## GUI: configurable repeating key

1. Install **AutoHotkey v2**.
2. Download [TDS-Ability-Macro.ahk](TDS-Ability-Macro.ahk) and double-click it to launch the desktop window.
3. Enter the repeat interval in the **Repeat interval** field.
4. Choose **Seconds** or **Milliseconds** from the **Time unit** dropdown:
   - Seconds: **0.1 to 3600** (decimals supported, e.g. 0.5).
   - Milliseconds: **10 to 3,600,000** (e.g. 250 for a quarter second).
5. Set **Key to repeat** to one key: A-Z, 0-9, F1-F12, Space, Enter, or Tab.
6. Click **Start**. The selected key is sent at each interval.
7. Click **Stop** or press **F6** to toggle start/stop. Press **F8** to exit.

The window displays the running status, number of key presses, and last press time. After starting, focus the intended application before the first press. The macro sends input to whichever window is active when the timer fires, so double-check the focused window. Very short timer intervals can be affected by Windows and AutoHotkey timer scheduling.

## Notes

- This prototype repeats one key only; it does not click the mouse or support key combinations.
- Keep the stop shortcut handy and test with a harmless key first.
- Use automation only where allowed by the game and platform rules.

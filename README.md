# TDS Ability Macro

A small AutoHotkey v2 project for prototyping timed keyboard actions.

## GUI: multiple repeating-key fields

1. Install **AutoHotkey v2**.
2. Download [TDS-Ability-Macro.ahk](TDS-Ability-Macro.ahk) and double-click it to launch the desktop window.
3. Use each row's **Hotkey** dropdown to choose a key, enter an interval, and choose **Seconds** or **Milliseconds**.
   - Seconds: **0.1 to 3600** (decimals supported, e.g. 0.5).
   - Milliseconds: **10 to 3,600,000** (e.g. 250 for a quarter second).
4. Click **+ Add Fields** to add up to 8 rows. Each row repeats its own selected key independently.
5. The key dropdown includes letters, numbers, common punctuation and shifted symbols such as backtick, backslash, <, >, ?, :, double quote, braces, pipe, tilde, underscore, plus, parentheses, and other number-row symbols.
6. Click **Start All** to start every row, or **Stop All** / **F6** to stop or restart. Press **F8** to exit.

The window displays the total number of key presses. Focus the intended application before starting because input goes to whichever window is active when a timer fires.

Very short timer intervals can be affected by Windows and AutoHotkey scheduling. Use automation only where allowed by the game and platform rules, and test with a harmless key first.


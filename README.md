# TDS Ability Macro

A small AutoHotkey v2 project for prototyping timed actions for personal testing.

## First test: repeating timer

1. Install **AutoHotkey v2**.
2. Download `TDS-Ability-Macro.ahk` from this repository.
3. Double-click the file to run it.
4. Press **F6** to start the timer. A tooltip appears every 5 seconds.
5. Press **F6** again to stop the timer.
6. Press **F8** to exit the script.

## Change the interval

Open the `.ahk` file and change:

```ahk
intervalMs := 5000
```

The interval is in milliseconds: `1000` = 1 second, `5000` = 5 seconds, `10000` = 10 seconds.

This first version only tests the timer and does not send keyboard or mouse input. Add and test input actions separately, with the game window focused only when intended.

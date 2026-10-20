# TDS Macro Studio

A configurable AutoHotkey v2 desktop macro with separate sections for timed abilities and hold-to-spam keys.

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## Run

1. Download the repository ZIP and extract the entire folder, keeping the `src` and `pictures` folders beside the launcher.
2. Double-click `TDS-Ability-Macro.ahk`.
3. In **Timed Abilities**, set a **Trigger Hotkey**, the **Ability Key / SendInput sequence**, and an interval for each row. Press a trigger once to start that row repeating; press it again to pause that row.
4. Use **Hold-to-Spam Keys** for keys that repeat only while you physically hold the configured key; releasing the key stops repeats.
5. Select a tab and use **Add to Section** to add a row to that section.
6. Use **Start All**, **Stop All**, or **F6** to control enabled rows. **F8** exits.
7. Use **Save Profile** and **Load Profile** to store both sections in the automatically created `profiles` folder.

## Project layout

- `TDS-Ability-Macro.ahk` — launcher and dashboard tabs; embeds the TDS icon when compiled with Ahk2Exe.
- `src/FieldUI.ahk` — row controls and independent scrolling for each tab.
- `src/MacroEngine.ahk` — scheduling, validation, and key dispatch.
- `src/Profiles.ahk` — INI profile save/load for both sections.
- `src/Credits.ahk` — separate Credits / About window and GitHub repository link.
- `src/StrategyWindow.ahk` — always-on-top strategy helper with an embedded WebView2 preview and saved Google Docs, Sheets, or Slides link.
- `lib/WebView2/WebView2.ahk`, `lib/Promise.ahk`, and `lib/ComVar.ahk` — WebView2 AutoHotkey wrapper and its dependencies.
- `src/WindowIcon.ahk` — applies the bundled TDS window icon.
- `pictures/TDS-icon.ico` — default window icon and compiled executable icon.
- `pictures/xpl.png` and `pictures/chatgpt.png` — optional circular profile pictures for the Credits window.
- `profiles/` — created automatically when saving or loading profiles.

## Features

- Separate **Timed Abilities** and **Hold-to-Spam Keys** sections.
- Up to 8 rows in each section.
- Timed rows have independent configurable trigger hotkeys (for example `F1`, `^e` for Ctrl+E, or `!q` for Alt+Q), output keys / SendInput sequences such as `{F1}`, and repeat intervals. Press each trigger to toggle only its own timer.
- Enabled timed trigger hotkeys must be unique and must not conflict with reserved shortcuts such as F6 (start/stop) and F8 (exit).
- Hold rows support letters, numbers, F1-F12, Space, Enter, Tab, Escape, Backspace, Delete, Insert, Home/End, Page Up/Down, and arrow keys.
- Intervals in seconds (0.1-3600) or milliseconds (10-3,600,000).
- Per-row enable toggles, add/remove controls, and independent scrolling.
- Profile save/load stores both sections and can import profiles from the previous single-list version.
- Live status and total key-press counter.
- **F6** toggles start/stop; **F8** exits.
- The TDS icon is applied to the running window/taskbar when `pictures/TDS-icon.ico` is present.
- **Pinned Strategy** embeds a Google Docs, Sheets, or Slides preview in an always-on-top, resizable window. It remembers the last URL in `strategy.ini`, with an **Open Browser** fallback. Editing URLs are normalized to `/preview`.

## Compile to EXE

1. Install AutoHotkey v2 and open **Ahk2Exe**.
2. Select `TDS-Ability-Macro.ahk` as the source file.
3. Choose an output filename ending in `.exe`.
4. Keep `pictures/TDS-icon.ico` in the same folder structure as the script while compiling. The `;@Ahk2Exe-SetMainIcon pictures\TDS-icon.ico` directive sets the executable's icon.
5. Compile. Check the resulting EXE in File Explorer; Windows may cache old icons, so refresh or reopen the folder if needed.

## Notes

Keyboard input is sent to whichever window is active when a timer fires, so focus the intended application before starting. Start All registers the configured timed trigger hotkeys; it does not immediately activate every timed row. Very short intervals are subject to Windows and AutoHotkey scheduling. Test with a harmless key first and use automation only where allowed by the game and platform rules.

The strategy viewer uses Microsoft Edge WebView2. The WebView2 Runtime is built into most Windows 11 installations; if it is missing, install the Evergreen Runtime from [Microsoft's WebView2 page](https://developer.microsoft.com/en-us/microsoft-edge/webview2/). The native loader DLL must also be present: obtain the `Microsoft.Web.WebView2` NuGet package and copy `runtimes/win-x64/native/WebView2Loader.dll` to `lib/64bit/WebView2Loader.dll` for 64-bit AutoHotkey, or the matching `win-x86` DLL to `lib/32bit/WebView2Loader.dll` for 32-bit AutoHotkey. The wrapper source is from [thqby/ahk2_lib](https://github.com/thqby/ahk2_lib) and includes its Promise and COM variant dependencies. Google sharing permissions still apply, and some documents may require Google to permit preview embedding. This integration has not been runtime-tested on your Windows machine yet.

## Credits pictures

The **Credits / About** button opens a separate window with cards for `xpl` and ChatGPT plus a button linking to the GitHub repository. Add your own portraits as `pictures/xpl.png` and `pictures/chatgpt.png`. For a circular avatar effect, use square PNGs with the area outside the circle transparent; the app uses a simple fallback initial when an image is missing. Keep the `pictures` folder beside the launcher and `src` folder.

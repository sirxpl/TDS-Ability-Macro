#Requires AutoHotkey v2.0
#SingleInstance Force
; Embed the TDS icon into compiled executables when using Ahk2Exe.
;@Ahk2Exe-SetMainIcon pictures\TDS-icon.ico

; TDS Macro Studio - timed abilities and dedicated hold-to-spam keys.
; F6: Start/stop all enabled actions. F8: Exit.
; Use only where permitted by the game/platform rules.

running := false
currentWindowIcon := 0
tickCount := 0
macroRows := []
holdRows := []
fieldScroll := 0
holdScroll := 0
visibleRows := 5

defaultIconPath := A_ScriptDir "\pictures\TDS-icon.ico"
; AutoHotkey initializes a GUI window icon from the current tray icon, so set
; the tray icon BEFORE creating the GUI (then WM_SETICON is applied after Show).
if FileExist(defaultIconPath)
    TraySetIcon(defaultIconPath)

mainGui := Gui("+MinSize860x600", "TDS Macro Studio")
mainGui.BackColor := "1E1E2E"
mainGui.AddText("x0 y0 w165 h600 Background181825", "")
mainGui.SetFont("s13 cB4Befe Bold", "Segoe UI")
mainGui.AddText("x18 y24 w130 h28", "TDS")
mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x18 y54 w130 h22", "MACRO STUDIO")
mainGui.AddText("x18 y105 w130 h20", "WORKSPACE")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x18 y133 w130 h44", "Ability`n scheduler")
mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x18 y220 w130 h20", "QUICK KEYS")
mainGui.AddText("x18 y247 w130 h20", "F6  Start / Stop")
mainGui.AddText("x18 y270 w130 h20", "F8  Exit")
mainGui.AddText("x18 y318 w130 h38", "Timed abilities and`n hold keys are separate.")
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")
mainGui.AddText("x190 y24 w650 h32 +0x200", "TDS MACRO STUDIO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x190 y59 w650 h22", "Ability scheduler  /  Configure, save, and reuse your loadouts")

statusText := mainGui.AddText("x190 y91 w650 h22 +0x200", "Status: STOPPED")
tickText := mainGui.AddText("x190 y116 w650 h20", "Key presses: 0")

sectionTabs := mainGui.AddTab3("x190 y143 w650 h280", ["Timed Abilities", "Hold-to-Spam Keys", "Discord RPC", "Game Detection"])
sectionTabs.UseTab(1)
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x205 y174 w40 h20", "On")
mainGui.AddText("x250 y174 w100 h20", "Trigger Hotkey")
mainGui.AddText("x360 y174 w100 h20", "Ability Key")
mainGui.AddText("x470 y174 w70 h20", "Interval")
mainGui.AddText("x550 y174 w105 h20", "Time unit")
sectionTabs.UseTab(2)
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x205 y174 w600 h32", "Hold the configured key to repeat it at the chosen interval. Release to stop.")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x205 y210 w40 h20", "On")
mainGui.AddText("x250 y210 w170 h20", "Trigger / repeated key")
mainGui.AddText("x430 y210 w80 h20", "Interval")
mainGui.AddText("x520 y210 w135 h20", "Time unit")
sectionTabs.UseTab(3)
mainGui.SetFont("s11 cB4Befe Bold", "Segoe UI")
mainGui.AddText("x210 y177 w580 h28", "Discord Rich Presence")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x210 y210 w580 h36", "Customize the Discord activity shown while TDS Macro Studio is open.")
discordRPCEnableCheck := mainGui.AddCheckbox("x210 y255 w250 h26 cF0F0F0", "Enable Discord Rich Presence")
discordRPCAppLabel := mainGui.AddText("x210 y294 w580 h20", "Discord Application ID")
discordRPCAppEdit := mainGui.AddEdit("x210 y317 w420 h28 Background28283A cFFFFFF", "")
discordRPCSaveButton := mainGui.AddButton("x645 y315 w150 h32", "Save RPC Settings")
discordRPCStatusText := mainGui.AddText("x210 y357 w580 h34 cB8C0D9", "Set your Application ID from the Discord Developer Portal, then save.")
discordRPCSaveButton.OnEvent("Click", SaveDiscordRPCSettings)
LoadDiscordRPCSettings()
sectionTabs.UseTab(4)
mainGui.SetFont("s11 cB4Befe Bold", "Segoe UI")
mainGui.AddText("x210 y177 w580 h28", "TDS Game Detection")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x210 y210 w580 h34", "Checks for the Roblox game window automatically while the macro is open.")
tdsDetectionStatusText := mainGui.AddText("x210 y255 w580 h26 cF0F0F0", "Status: Waiting for Roblox")
tdsDetectedMapText := mainGui.AddText("x210 y286 w580 h24 cF0F0F0", "Map: Unknown")
tdsDetectedModeText := mainGui.AddText("x210 y315 w280 h24 cF0F0F0", "Gamemode: Unknown")
tdsDetectedPlayersText := mainGui.AddText("x500 y315 w180 h24 cF0F0F0", "Players: Unknown")
mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x210 y345 w145 h20", "Manual Map")
mainGui.AddText("x365 y345 w145 h20", "Manual Gamemode")
mainGui.AddText("x520 y345 w100 h20", "Players (1-4)")
tdsManualMapEdit := mainGui.AddEdit("x210 y365 w145 h26 Background28283A cFFFFFF", "")
tdsManualModeEdit := mainGui.AddEdit("x365 y365 w145 h26 Background28283A cFFFFFF", "")
tdsManualPlayersEdit := mainGui.AddEdit("x520 y365 w100 h26 Background28283A cFFFFFF", "")
tdsManualSetupCheck := mainGui.AddCheckbox("x210 y395 w260 h22 cF0F0F0", "Use manual values")
tdsManualApplyButton := mainGui.AddButton("x520 y393 w150 h28", "Apply Game Setup")
tdsManualApplyButton.OnEvent("Click", SaveManualGameSetup)
sectionTabs.UseTab()

addButton := mainGui.AddButton("x190 y434 w140 h34", "+ Add to Section")
scrollUpButton := mainGui.AddButton("x340 y434 w65 h34", "↑ Up")
scrollDownButton := mainGui.AddButton("x415 y434 w75 h34", "↓ Down")
startButton := mainGui.AddButton("x520 y434 w125 h34", "▶ Start All")
stopButton := mainGui.AddButton("x670 y434 w125 h34", "■ Stop All")
addButton.OnEvent("Click", AddCurrentField)
scrollUpButton.OnEvent("Click", (*) => ScrollCurrentFields(-1))
scrollDownButton.OnEvent("Click", (*) => ScrollCurrentFields(1))
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x190 y482 w650 h20", "F6 = start / stop all    •    F8 = quit    •    Use Up/Down or the mouse wheel to scroll")
mainGui.AddText("x190 y505 w650 h24", "Timed: press a trigger hotkey to toggle its repeating ability. Use automation only where permitted.")

mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x190 y540 w105 h24", "Pinned Strategy")
; Darker input background and bright text make the paste-link field easier to spot.
strategyLinkEdit := mainGui.AddEdit("x300 y536 w360 h28 Background28283A cFFFFFF", "")
pinStrategyButton := mainGui.AddButton("x670 y534 w125 h32", "Pin Strategy")
pinStrategyButton.OnEvent("Click", PinStrategyFromMain)

profileSaveButton := mainGui.AddButton("x15 y390 w135 h34", "Save Profile")
profileLoadButton := mainGui.AddButton("x15 y434 w135 h34", "Load Profile")
creditsButton := mainGui.AddButton("x15 y478 w135 h34", "Credits / About")
profileSaveButton.OnEvent("Click", SaveProfile)
profileLoadButton.OnEvent("Click", LoadProfile)
creditsButton.OnEvent("Click", ShowCredits)


AddField()
AddHoldField()

; Show the GUI first so Windows has created its HWND before WM_SETICON is sent.
mainGui.Show("w860 h600")

if FileExist(defaultIconPath)
    ApplyWindowIconFile(defaultIconPath)
; Missing icon is non-fatal; the UI no longer has an icon status label.

#Include lib\WebView2\WebView2.ahk
#Include src\StrategyWindow.ahk

F6::ToggleMacro()
F8::ExitApp

OnMessage(0x020A, HandleMouseWheel)
HandleMouseWheel(wParam, lParam, msg, hwnd) {
    delta := (wParam >> 16) & 0xFFFF
    if (delta >= 0x8000)
        delta -= 0x10000
    if (delta < 0)
        ScrollCurrentFields(1)
    else if (delta > 0)
        ScrollCurrentFields(-1)
}

#Include src\FieldUI.ahk
#Include src\MacroEngine.ahk
#Include src\Profiles.ahk
#Include src\Credits.ahk
#Include src\WindowIcon.ahk

#Include src\DiscordRPC.ahk
#Include src\GameDetection.ahk

; Rich Presence is optional and never blocks the macro UI if Discord is unavailable.
StartDiscordPresence()
StartTDSGameDetection()
OnExit(StopDiscordPresence)
OnExit(StopTDSGameDetection)

#Requires AutoHotkey v2.0
#SingleInstance Force

; TDS Ability Macro - configurable repeating-key fields
; F6: Start/stop all fields
; F8: Exit the script
; Use only where permitted by the game/platform rules.

running := false
tickCount := 0
macroRows := []
fieldScroll := 0
visibleRows := 6

keyOptions := ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
    ,"0","1","2","3","4","5","6","7","8","9"
    ,"Backtick key","-","=","[","]","Backslash key",";","'",",",".","/"
    ,"< (Shift+,)","> (Shift+.)","? (Shift+/)",": (Shift+;)","Double quote (Shift+')","{ (Shift+[)","} (Shift+])","| (Shift+Backslash)","~ (Shift+Backtick)"
    ,"_ (Shift+-)","+ (Shift+=)",") (Shift+0)","( (Shift+9)","* (Shift+8)","& (Shift+7)","^ (Shift+6)","% (Shift+5)","$ (Shift+4)","# (Shift+3)","@ (Shift+2)","! (Shift+1)"
    ,"Space","Enter","Tab","Escape","Backspace","Delete","Insert","Home","End","PgUp","PgDn","Up","Down","Left","Right"
    ,"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"]

mainGui := Gui("+MinSize860x600", "TDS Macro Studio")
mainGui.BackColor := "1E1E2E"
mainGui.AddText("x0 y0 w165 h600 Background181825", "")
mainGui.SetFont("s13 cB4Befe Bold", "Segoe UI")
mainGui.AddText("x18 y24 w130 h28", "TDS")
mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x18 y54 w130 h22", "MACRO STUDIO")
mainGui.AddText("x18 y105 w130 h20", "WORKSPACE")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x18 y133 w130 h44", "Ability\nscheduler")
mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x18 y220 w130 h20", "QUICK KEYS")
mainGui.AddText("x18 y247 w130 h20", "F6  Start / Stop")
mainGui.AddText("x18 y270 w130 h20", "F8  Exit")
mainGui.AddText("x18 y318 w130 h38", "Profiles let you\nsave different loadouts.")
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")
mainGui.AddText("x190 y24 w650 h32 +0x200", "TDS MACRO STUDIO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x190 y59 w650 h22", "Ability scheduler  /  Configure, save, and reuse your loadouts")

statusText := mainGui.AddText("x190 y91 w650 h22 +0x200", "Status: STOPPED")
tickText := mainGui.AddText("x190 y116 w650 h20", "Key presses: 0")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x245 y149 w175 h20", "Key / SendInput")
mainGui.AddText("x430 y149 w80 h20", "Interval")
mainGui.AddText("x520 y149 w140 h20", "Time unit")

addButton := mainGui.AddButton("x190 y430 w140 h34", "+ Add Ability")
scrollUpButton := mainGui.AddButton("x350 y430 w65 h34", "↑ Up")
scrollDownButton := mainGui.AddButton("x425 y430 w75 h34", "↓ Down")
startButton := mainGui.AddButton("x520 y430 w125 h34", "▶ Start All")
stopButton := mainGui.AddButton("x670 y430 w125 h34", "■ Stop All")
addButton.OnEvent("Click", AddField)
scrollUpButton.OnEvent("Click", (*) => ScrollFields(-1))
scrollDownButton.OnEvent("Click", (*) => ScrollFields(1))
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
infoText1 := mainGui.AddText("x190 y478 w650 h20", "F6 = start / stop all    •    F8 = quit    •    Mouse wheel or arrows scroll abilities")
infoText2 := mainGui.AddText("x190 y501 w650 h24", "Input is sent to the active window. Use only where permitted by the game/platform.")

profileSaveButton := mainGui.AddButton("x15 y390 w135 h34", "Save Profile")
profileLoadButton := mainGui.AddButton("x15 y434 w135 h34", "Load Profile")
profileSaveButton.OnEvent("Click", SaveProfile)
profileLoadButton.OnEvent("Click", LoadProfile)

AddField()
mainGui.Show("w860 h600")

F6::ToggleMacro()
F8::ExitApp

; Scroll the field list with the mouse wheel while the GUI is active.
OnMessage(0x020A, HandleMouseWheel)
HandleMouseWheel(wParam, lParam, msg, hwnd) {
    delta := (wParam >> 16) & 0xFFFF
    if (delta >= 0x8000)
        delta -= 0x10000
    if (delta < 0)
        ScrollFields(1)
    else if (delta > 0)
        ScrollFields(-1)
}

#Include src\FieldUI.ahk
#Include src\MacroEngine.ahk
#Include src\Profiles.ahk

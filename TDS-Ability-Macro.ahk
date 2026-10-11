#Requires AutoHotkey v2.0
#SingleInstance Force

; TDS Ability Macro - configurable repeating-key prototype
; F6: Start/stop repeating key
; F8: Exit the script
; Use only where permitted by the game/platform rules.

global running := false
global intervalMs := 5000
global repeatKey := "Q"
global tickCount := 0

mainGui := Gui("+MinSize460x370", "TDS Ability Macro")
mainGui.BackColor := "1E1E2E"
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")

mainGui.AddText("x20 y18 w400 h28 +0x200", "TDS ABILITY MACRO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y48 w400 h24", "Configurable repeating-key prototype")

global statusText := mainGui.AddText("x20 y84 w400 h26 +0x200", "Status: STOPPED")
global tickText := mainGui.AddText("x20 y112 w400 h22", "Key presses: 0")
global lastTickText := mainGui.AddText("x20 y134 w400 h22", "Last press: —")

mainGui.SetFont("s10 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y174 w180 h22", "Interval (seconds)")
global secondsEdit := mainGui.AddEdit("x20 y198 w180 h30", "5")
mainGui.AddText("x230 y174 w180 h22", "Key to repeat")
global keyEdit := mainGui.AddEdit("x230 y198 w180 h30", "Q")

startButton := mainGui.AddButton("x20 y244 w185 h34", "Start")
stopButton := mainGui.AddButton("x220 y244 w190 h34", "Stop")
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y292 w420 h20", "Allowed keys: A-Z, 0-9, F1-F12, Space, Enter, Tab")
mainGui.AddText("x20 y313 w420 h20", "F6 = toggle start/stop    •    F8 = quit")
mainGui.AddText("x20 y334 w420 h24", "After starting, focus the intended window before the first press.")
mainGui.Show("w460 h370")

F6::ToggleMacro()
F8::ExitApp

StartMacro(*) {
    global running, intervalMs, repeatKey, secondsEdit, keyEdit, statusText

    secondsText := Trim(secondsEdit.Value)
    keyText := Trim(keyEdit.Value)

    if !RegExMatch(secondsText, "^\d+(?:\.\d+)?$") {
        MsgBox("Enter an interval in seconds, such as 2 or 0.5.", "Invalid interval", "Icon!")
        return
    }

    seconds := Float(secondsText)
    if (seconds < 0.1 || seconds > 3600) {
        MsgBox("Interval must be between 0.1 and 3600 seconds.", "Invalid interval", "Icon!")
        return
    }

    if !RegExMatch(keyText, "i)^(?:[a-z]|[0-9]|F(?:[1-9]|1[0-2])|Space|Enter|Tab)$") {
        MsgBox("Use one key: A-Z, 0-9, F1-F12, Space, Enter, or Tab.", "Invalid key", "Icon!")
        return
    }

    intervalMs := Max(100, Round(seconds * 1000))
    repeatKey := keyText

    if running
        SetTimer(TestAction, 0)

    running := true
    statusText.Text := "Status: RUNNING — pressing " repeatKey
    SetTimer(TestAction, intervalMs)
}

StopMacro(*) {
    global running, statusText

    running := false
    SetTimer(TestAction, 0)
    statusText.Text := "Status: STOPPED"
}

ToggleMacro(*) {
    global running

    if running
        StopMacro()
    else
        StartMacro()
}

TestAction() {
    global running, repeatKey, tickCount, tickText, lastTickText

    if !running
        return

    SendInput("{" repeatKey "}")
    tickCount += 1
    tickText.Text := "Key presses: " tickCount
    lastTickText.Text := "Last press: " FormatTime(, "HH:mm:ss")
}

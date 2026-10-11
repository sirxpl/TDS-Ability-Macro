#Requires AutoHotkey v2.0
#SingleInstance Force

; TDS Ability Macro - GUI timer prototype
; F6: Start/stop timer
; F8: Exit the script
; This prototype only demonstrates timing; it does not send game inputs.

global running := false
global intervalMs := 5000
global tickCount := 0

mainGui := Gui("+MinSize420x300", "TDS Ability Macro")
mainGui.BackColor := "1E1E2E"
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")

mainGui.AddText("x20 y18 w380 h28 +0x200", "TDS ABILITY MACRO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y48 w380 h24", "Timer prototype • AutoHotkey v2")

global statusText := mainGui.AddText("x20 y84 w380 h26 +0x200", "Status: STOPPED")
global tickText := mainGui.AddText("x20 y112 w380 h22", "Test ticks: 0")
global lastTickText := mainGui.AddText("x20 y134 w380 h22", "Last tick: —")

mainGui.AddText("x20 y170 w130 h22", "Interval")
global intervalDrop := mainGui.AddDropDownList("x20 y194 w170 Choose2", ["1 second", "5 seconds", "10 seconds", "30 seconds"])

startButton := mainGui.AddButton("x210 y194 w90 h30", "Start")
stopButton := mainGui.AddButton("x310 y194 w90 h30", "Stop")
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y244 w390 h20", "F6 = toggle timer    •    F8 = quit")
mainGui.AddText("x20 y264 w390 h20", "This test does not press keys or click in the game.")
mainGui.Show("w440 h300")

F6::ToggleMacro()
F8::ExitApp

StartMacro(*) {
    global running, intervalMs, intervalDrop, statusText

    choice := intervalDrop.Text
    switch choice {
        case "1 second":
            intervalMs := 1000
        case "5 seconds":
            intervalMs := 5000
        case "10 seconds":
            intervalMs := 10000
        case "30 seconds":
            intervalMs := 30000
    }

    if running
        SetTimer(TestAction, 0)

    running := true
    statusText.Text := "Status: RUNNING"
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
    global tickCount, tickText, lastTickText

    tickCount += 1
    tickText.Text := "Test ticks: " tickCount
    lastTickText.Text := "Last tick: " FormatTime(, "HH:mm:ss")
}

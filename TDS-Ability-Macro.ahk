#Requires AutoHotkey v2.0
#SingleInstance Force

; TDS Ability Macro - timer test
; F6: Start/stop the test timer
; F8: Exit the script

running := false
intervalMs := 5000

F6:: {
    global running, intervalMs

    running := !running

    if running {
        ToolTip("Timer test RUNNING - every " (intervalMs / 1000) " seconds")
        SetTimer(ClearToolTip, -1500)
        SetTimer(TestAction, intervalMs)
    } else {
        SetTimer(TestAction, 0)
        ToolTip("Timer test STOPPED")
        SetTimer(ClearToolTip, -1500)
    }
}

TestAction() {
    ToolTip("Test tick: " FormatTime(, "HH:mm:ss"))
    SetTimer(ClearToolTip, -1200)
}

ClearToolTip() {
    ToolTip()
}

F8::ExitApp

#Requires AutoHotkey v2.0
#SingleInstance Force

; TDS Ability Macro - configurable repeating-key fields
; F6: Start/stop all fields
; F8: Exit the script
; Use only where permitted by the game/platform rules.

running := false
tickCount := 0
macroRows := []

keyOptions := ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
    ,"0","1","2","3","4","5","6","7","8","9"
    ,"Backtick (`)","-","=","[","]","\\",";","' ",",",".","/"
    ,"Space","Enter","Tab","Escape","Backspace","Delete","Insert","Home","End","PgUp","PgDn","Up","Down","Left","Right"
    ,"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"]

mainGui := Gui("+MinSize540x300", "TDS Ability Macro")
mainGui.BackColor := "1E1E2E"
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y18 w500 h28 +0x200", "TDS ABILITY MACRO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y48 w500 h22", "Add independent repeating-key fields")

statusText := mainGui.AddText("x20 y78 w500 h22 +0x200", "Status: STOPPED")
tickText := mainGui.AddText("x20 y101 w500 h20", "Key presses: 0")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y133 w145 h20", "Hotkey")
mainGui.AddText("x180 y133 w80 h20", "Interval")
mainGui.AddText("x270 y133 w140 h20", "Time unit")

addButton := mainGui.AddButton("x20 y180 w160 h32", "+ Add Fields")
startButton := mainGui.AddButton("x190 y180 w150 h32", "Start All")
stopButton := mainGui.AddButton("x350 y180 w150 h32", "Stop All")
addButton.OnEvent("Click", AddField)
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y220 w500 h36", "F6 = toggle all fields  •  F8 = quit. Each row repeats independently.")
mainGui.AddText("x20 y254 w500 h32", "Seconds: 0.1–3600 | Milliseconds: 10–3600000. Focus the intended app before starting.")

AddField()
mainGui.Show("w540 h300")

F6::ToggleMacro()
F8::ExitApp

AddField(*) {
    global macroRows, keyOptions, addButton, startButton, stopButton, mainGui
    if (macroRows.Length >= 8) {
        MsgBox("You can add up to 8 macro fields.", "Field limit", "Icon!")
        return
    }

    rowIndex := macroRows.Length + 1
    y := 156 + (rowIndex - 1) * 42
    row := {}
    row.key := mainGui.AddDropDownList("x20 y" y " w145 Choose17", keyOptions)
    row.interval := mainGui.AddEdit("x180 y" y " w80 h25", "5")
    row.unit := mainGui.AddDropDownList("x270 y" y " w140 Choose1", ["Seconds", "Milliseconds"])
    row.remove := mainGui.AddButton("x420 y" y " w80 h25", "Remove")
    row.remove.OnEvent("Click", (*) => RemoveField(row))
    row.intervalMs := 5000
    row.nextTick := 0
    macroRows.Push(row)
    RefreshLayout()
}

RemoveField(rowToRemove, *) {
    global macroRows
    if (macroRows.Length <= 1) {
        MsgBox("Keep at least one macro field.", "Cannot remove", "Icon!")
        return
    }
    for index, row in macroRows {
        if (row = rowToRemove) {
            row.key.Visible := false
            row.interval.Visible := false
            row.unit.Visible := false
            row.remove.Visible := false
            macroRows.RemoveAt(index)
            break
        }
    }
    RefreshLayout()
}

RefreshLayout() {
    global macroRows, addButton, startButton, stopButton, mainGui
    for index, row in macroRows {
        y := 156 + (index - 1) * 42
        row.key.Move(20, y, 145, 27)
        row.interval.Move(180, y, 80, 27)
        row.unit.Move(270, y, 140, 27)
        row.remove.Move(420, y, 80, 27)
        row.key.Visible := true
        row.interval.Visible := true
        row.unit.Visible := true
        row.remove.Visible := true
    }
    buttonsY := 180 + macroRows.Length * 42
    addButton.Move(20, buttonsY, 160, 32)
    startButton.Move(190, buttonsY, 150, 32)
    stopButton.Move(350, buttonsY, 150, 32)
    mainGui["Static6"].Move(20, buttonsY + 40, 500, 20)
    mainGui["Static7"].Move(20, buttonsY + 62, 500, 32)
    mainGui.Show("w540 h" (buttonsY + 105))
}

StartMacro(*) {
    global running, macroRows, statusText, tickCount, tickText
    for index, row in macroRows {
        intervalText := Trim(row.interval.Value)
        if !RegExMatch(intervalText, "^\d+(?:\.\d+)?$") {
            MsgBox("Field " index ": enter a valid interval number.", "Invalid interval", "Icon!")
            return
        }
        intervalValue := Float(intervalText)
        if (row.unit.Text = "Seconds") {
            if (intervalValue < 0.1 || intervalValue > 3600) {
                MsgBox("Field " index ": seconds must be between 0.1 and 3600.", "Invalid interval", "Icon!")
                return
            }
            row.intervalMs := Max(100, Round(intervalValue * 1000))
        } else {
            if (intervalValue < 10 || intervalValue > 3600000) {
                MsgBox("Field " index ": milliseconds must be between 10 and 3600000.", "Invalid interval", "Icon!")
                return
            }
            row.intervalMs := Round(intervalValue)
        }
        row.nextTick := A_TickCount + row.intervalMs
    }
    tickCount := 0
    tickText.Text := "Key presses: 0"
    running := true
    statusText.Text := "Status: RUNNING — all fields active"
    SetTimer(ProcessMacros, 10)
}

StopMacro(*) {
    global running, statusText
    running := false
    SetTimer(ProcessMacros, 0)
    statusText.Text := "Status: STOPPED"
}

ToggleMacro(*) {
    global running
    if running
        StopMacro()
    else
        StartMacro()
}

ProcessMacros() {
    global running, macroRows, tickCount, tickText
    if !running
        return
    now := A_TickCount
    for index, row in macroRows {
        if (now >= row.nextTick) {
            keyName := KeyNameFor(row.key.Text)
            SendInput("{" keyName "}")
            tickCount += 1
            tickText.Text := "Key presses: " tickCount
            row.nextTick := now + row.intervalMs
        }
    }
}

KeyNameFor(label) {
    if (label = "Backtick (`)")
        return "`"
    if (label = "' ")
        return "'"
    return label
}

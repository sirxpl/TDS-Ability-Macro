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
visibleRows := 4

keyOptions := ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
    ,"0","1","2","3","4","5","6","7","8","9"
    ,"Backtick key","-","=","[","]","Backslash key",";","'",",",".","/"
    ,"< (Shift+,)","> (Shift+.)","? (Shift+/)",": (Shift+;)","Double quote (Shift+')","{ (Shift+[)","} (Shift+])","| (Shift+Backslash)","~ (Shift+Backtick)"
    ,"_ (Shift+-)","+ (Shift+=)",") (Shift+0)","( (Shift+9)","* (Shift+8)","& (Shift+7)","^ (Shift+6)","% (Shift+5)","$ (Shift+4)","# (Shift+3)","@ (Shift+2)","! (Shift+1)"
    ,"Space","Enter","Tab","Escape","Backspace","Delete","Insert","Home","End","PgUp","PgDn","Up","Down","Left","Right"
    ,"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"]

mainGui := Gui("+MinSize540x480", "TDS Ability Macro")
mainGui.BackColor := "1E1E2E"
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y18 w500 h28 +0x200", "TDS ABILITY MACRO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y48 w500 h22", "Add independent repeating-key fields")

statusText := mainGui.AddText("x20 y78 w500 h22 +0x200", "Status: STOPPED")
tickText := mainGui.AddText("x20 y101 w500 h20", "Key presses: 0")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y133 w145 h20", "Key / SendInput")
mainGui.AddText("x180 y133 w80 h20", "Interval")
mainGui.AddText("x270 y133 w140 h20", "Time unit")

addButton := mainGui.AddButton("x20 y350 w145 h32", "+ Add Field")
scrollUpButton := mainGui.AddButton("x175 y350 w70 h32", "Up")
scrollDownButton := mainGui.AddButton("x250 y350 w85 h32", "Down")
startButton := mainGui.AddButton("x345 y350 w75 h32", "Start")
stopButton := mainGui.AddButton("x430 y350 w70 h32", "Stop")
addButton.OnEvent("Click", AddField)
scrollUpButton.OnEvent("Click", (*) => ScrollFields(-1))
scrollDownButton.OnEvent("Click", (*) => ScrollFields(1))
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
infoText1 := mainGui.AddText("x20 y392 w500 h20", "F6 = toggle all fields  •  F8 = quit. Mouse wheel or Up/Down scrolls fields.")
infoText2 := mainGui.AddText("x20 y414 w500 h32", "Type a key or SendInput text, e.g. q, {F1}, or Hello. Use only where permitted.")

AddField()
mainGui.Show("w540 h480")

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

AddField(*) {
    global macroRows, mainGui
    if (macroRows.Length >= 8) {
        MsgBox("You can add up to 8 macro fields.", "Field limit", "Icon!")
        return
    }

    rowIndex := macroRows.Length + 1
    row := {}
    y := 156
    ; Editable key field: accepts a key name, symbol, or SendInput sequence.
    mainGui.SetFont("s9 c202030", "Segoe UI")
    row.key := mainGui.AddEdit("x20 y156 w145 h27", "q")
    row.interval := mainGui.AddEdit("x180 y156 w80 h27", "5")
    row.unit := mainGui.AddDropDownList("x270 y156 w140 Choose1", ["Seconds", "Milliseconds"])
    mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
    row.remove := mainGui.AddButton("x420 y156 w80 h25", "Remove")
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
    global macroRows, fieldScroll, visibleRows
    maxScroll := Max(0, macroRows.Length - visibleRows)
    fieldScroll := Min(fieldScroll, maxScroll)
    for index, row in macroRows {
        slot := index - 1 - fieldScroll
        if (slot >= 0 && slot < visibleRows) {
            y := 156 + slot * 42
            row.key.Move(20, y, 145, 27)
            row.interval.Move(180, y, 80, 27)
            row.unit.Move(270, y, 140, 27)
            row.remove.Move(420, y, 80, 27)
            row.key.Visible := true
            row.interval.Visible := true
            row.unit.Visible := true
            row.remove.Visible := true
        } else {
            row.key.Visible := false
            row.interval.Visible := false
            row.unit.Visible := false
            row.remove.Visible := false
        }
    }
}

ScrollFields(direction, *) {
    global fieldScroll, macroRows, visibleRows
    fieldScroll := Max(0, Min(fieldScroll + direction, Max(0, macroRows.Length - visibleRows)))
    RefreshLayout()
}

StartMacro(*) {
    global running, macroRows, statusText, tickCount, tickText
    for index, row in macroRows {
        if (Trim(row.key.Value) = "") {
            MsgBox("Field " index ": type a key or SendInput sequence.", "Missing key", "Icon!")
            return
        }
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
            SendInput(row.key.Value)
            tickCount += 1
            tickText.Text := "Key presses: " tickCount
            row.nextTick := now + row.intervalMs
        }
    }
}

KeySequenceFor(label) {
    static shifted := Map(
        "< (Shift+,)", "+{,}", "> (Shift+.)", "+{.}", "? (Shift+/)", "+{/}",
        ": (Shift+;)", "+{;}", "Double quote (Shift+')", "+{'}",
        "{ (Shift+[)", "+{[}", "} (Shift+])", "+{]}", "| (Shift+Backslash)", "+{\\}",
        "~ (Shift+Backtick)", "+{``}", "_ (Shift+-)", "+{-}", "+ (Shift+=)", "+{=}",
        ") (Shift+0)", "+{0}", "( (Shift+9)", "+{9}", "* (Shift+8)", "+{8}",
        "& (Shift+7)", "+{7}", "^ (Shift+6)", "+{6}", "% (Shift+5)", "+{5}",
        "$ (Shift+4)", "+{4}", "# (Shift+3)", "+{3}", "@ (Shift+2)", "+{2}", "! (Shift+1)", "+{1}"
    )
    if shifted.Has(label)
        return shifted[label]
    if (label = "Backtick key")
        return "{``}"
    if (label = "Backslash key")
        return "{\\}"
    return "{" label "}"
}

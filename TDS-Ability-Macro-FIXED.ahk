#Requires AutoHotkey v2.0
#SingleInstance Force

; TDS Ability Macro - configurable repeating-key fields
; F6: Start/stop all fields
; F8: Exit the script
; Use only where permitted by the game/platform rules.

running := false
tickCount := 0
registeredHotkeys := []
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

mainGui := Gui("+MinSize760x520", "TDS Ability Macro")
mainGui.BackColor := "1E1E2E"
mainGui.SetFont("s10 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y18 w500 h28 +0x200", "TDS ABILITY MACRO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x20 y48 w700 h22", "Custom global shortcuts + per-field triggers and repeating keys")

statusText := mainGui.AddText("x20 y78 w700 h22 +0x200", "Status: STOPPED")
tickText := mainGui.AddText("x20 y101 w700 h20", "Key presses: 0")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x20 y128 w100 h20", "Start/Stop")
mainGui.AddText("x135 y128 w100 h20", "Exit")
mainGui.AddText("x250 y128 w100 h20", "Field trigger")
mainGui.AddText("x365 y128 w120 h20", "Repeating key")
mainGui.AddText("x495 y128 w75 h20", "Interval")
mainGui.AddText("x580 y128 w120 h20", "Time unit")
mainGui.SetFont("s9 c202030", "Segoe UI")
startHotkeyEdit := mainGui.AddEdit("x20 y148 w100 h26", "F6")
exitHotkeyEdit := mainGui.AddEdit("x135 y148 w100 h26", "F8")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
applyHotkeysButton := mainGui.AddButton("x585 y180 w115 h28", "Apply Keybinds")
applyHotkeysButton.OnEvent("Click", ApplyKeybinds)

addButton := mainGui.AddButton("x20 y390 w145 h32", "+ Add Field")
scrollUpButton := mainGui.AddButton("x175 y390 w70 h32", "Up")
scrollDownButton := mainGui.AddButton("x250 y390 w85 h32", "Down")
startButton := mainGui.AddButton("x345 y390 w100 h32", "Start All")
stopButton := mainGui.AddButton("x455 y390 w100 h32", "Stop All")
addButton.OnEvent("Click", AddField)
scrollUpButton.OnEvent("Click", (*) => ScrollFields(-1))
scrollDownButton.OnEvent("Click", (*) => ScrollFields(1))
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
infoText1 := mainGui.AddText("x20 y432 w700 h20", "Global shortcuts default to F6 (Start/Stop) and F8 (Exit). Field triggers toggle each field on/off.")
infoText2 := mainGui.AddText("x20 y454 w700 h36", "Hotkeys use AutoHotkey syntax: q, F1, ^q (Ctrl+Q), !q (Alt+Q), +q (Shift+Q). Duplicate bindings are blocked.")

AddField()
ApplyKeybinds()
mainGui.Show("w760 h520")

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


ApplyKeybinds(*) {
    global macroRows, startHotkeyEdit, exitHotkeyEdit, registeredHotkeys
    startKey := Trim(startHotkeyEdit.Value)
    exitKey := Trim(exitHotkeyEdit.Value)
    if (startKey = "" || exitKey = "") {
        MsgBox("Set both global shortcuts before applying.", "Missing keybind", "Icon!")
        return false
    }
    seen := Map()
    if (StrLower(startKey) = StrLower(exitKey)) {
        MsgBox("Start/Stop and Exit cannot use the same keybind.", "Duplicate keybind", "Icon!")
        return false
    }
    seen[StrLower(startKey)] := "Start/Stop"
    seen[StrLower(exitKey)] := "Exit"
    for index, row in macroRows {
        trigger := Trim(row.trigger.Value)
        if (trigger = "")
            continue
        keyId := StrLower(trigger)
        if seen.Has(keyId) {
            MsgBox("Field " index " uses '" trigger "', which conflicts with " seen[keyId] ". Give each trigger a unique keybind.", "Keybind conflict", "Icon!")
            return false
        }
        seen[keyId] := "Field " index
    }
    for oldKey in registeredHotkeys {
        try Hotkey(oldKey, "Off")
    }
    registeredHotkeys := []
    try {
        Hotkey(startKey, ToggleMacro, "On")
        registeredHotkeys.Push(startKey)
        Hotkey(exitKey, ExitApp, "On")
        registeredHotkeys.Push(exitKey)
        for index, row in macroRows {
            trigger := Trim(row.trigger.Value)
            if (trigger = "")
                continue
            Hotkey(trigger, (*) => ToggleField(row), "On")
            registeredHotkeys.Push(trigger)
        }
    } catch as err {
        for oldKey in registeredHotkeys {
            try Hotkey(oldKey, "Off")
        }
        registeredHotkeys := []
        MsgBox("Could not register a keybind. Check syntax like q, F1, ^q, !q, or +q." Chr(10) Chr(10) err.Message, "Invalid keybind", "Icon!")
        return false
    }
    return true
}

ToggleField(row) {
    global statusText
    row.enabled := !row.enabled
    if row.enabled {
        row.nextTick := A_TickCount + row.intervalMs
        statusText.Text := "Status: RUNNING — field enabled"
    } else {
        statusText.Text := "Status: RUNNING — field paused"
    }
}

AddField(*) {
    global macroRows, mainGui
    if (macroRows.Length >= 8) {
        MsgBox("You can add up to 8 macro fields.", "Field limit", "Icon!")
        return
    }

    rowIndex := macroRows.Length + 1
    row := {}
    row.enabled := true
    mainGui.SetFont("s9 c202030", "Segoe UI")
    row.trigger := mainGui.AddEdit("x250 y185 w100 h27", rowIndex = 1 ? "q" : "")
    row.key := mainGui.AddEdit("x365 y185 w120 h27", "1")
    row.interval := mainGui.AddEdit("x495 y185 w75 h27", "5")
    row.unit := mainGui.AddDropDownList("x580 y185 w120 Choose1", ["Seconds", "Milliseconds"])
    mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
    row.remove := mainGui.AddButton("x705 y185 w45 h27", "X")
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
            row.trigger.Visible := false
            row.trigger.Visible := false
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
            row.trigger.Move(250, y, 100, 27)
            row.key.Move(365, y, 120, 27)
            row.interval.Move(495, y, 75, 27)
            row.unit.Move(580, y, 120, 27)
            row.remove.Move(705, y, 45, 27)
            row.trigger.Visible := true
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
    if !ApplyKeybinds()
        return
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
    for row in macroRows
        row.enabled := true
    running := true
    statusText.Text := "Status: RUNNING — all fields active"
    SetTimer(ProcessMacros, 10)
}

StopMacro(*) {
    global running, statusText, macroRows
    running := false
    for row in macroRows
        row.enabled := false
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
        if (row.enabled && now >= row.nextTick) {
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

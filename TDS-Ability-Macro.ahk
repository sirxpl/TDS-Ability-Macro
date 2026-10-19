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

mainGui := Gui("+MinSize800x600", "TDS Macro Studio")
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
mainGui.AddText("x190 y24 w580 h32 +0x200", "TDS MACRO STUDIO")
mainGui.SetFont("s9 cB8C0D9", "Segoe UI")
mainGui.AddText("x190 y59 w580 h22", "Ability scheduler  /  Configure, save, and reuse your loadouts")

statusText := mainGui.AddText("x190 y91 w580 h22 +0x200", "Status: STOPPED")
tickText := mainGui.AddText("x190 y116 w580 h20", "Key presses: 0")
mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
mainGui.AddText("x250 y149 w145 h20", "Key / SendInput")
mainGui.AddText("x410 y149 w80 h20", "Interval")
mainGui.AddText("x500 y149 w140 h20", "Time unit")

addButton := mainGui.AddButton("x190 y430 w140 h34", "+ Add Ability")
scrollUpButton := mainGui.AddButton("x340 y430 w65 h34", "↑ Up")
scrollDownButton := mainGui.AddButton("x415 y430 w75 h34", "↓ Down")
startButton := mainGui.AddButton("x500 y430 w115 h34", "▶ Start All")
stopButton := mainGui.AddButton("x625 y430 w115 h34", "■ Stop All")
addButton.OnEvent("Click", AddField)
scrollUpButton.OnEvent("Click", (*) => ScrollFields(-1))
scrollDownButton.OnEvent("Click", (*) => ScrollFields(1))
startButton.OnEvent("Click", StartMacro)
stopButton.OnEvent("Click", StopMacro)

mainGui.SetFont("s8 cB8C0D9", "Segoe UI")
infoText1 := mainGui.AddText("x190 y478 w580 h20", "F6 = start / stop all    •    F8 = quit    •    Mouse wheel or arrows scroll abilities")
infoText2 := mainGui.AddText("x190 y501 w580 h24", "Input is sent to the active window. Use only where permitted by the game/platform.")

profileSaveButton := mainGui.AddButton("x15 y390 w135 h34", "Save Profile")
profileLoadButton := mainGui.AddButton("x15 y434 w135 h34", "Load Profile")
profileSaveButton.OnEvent("Click", SaveProfile)
profileLoadButton.OnEvent("Click", LoadProfile)

AddField()
mainGui.Show("w800 h600")

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
    row.enabled := mainGui.AddCheckBox("x190 y168 w50 h27 Checked", "On")
    row.key := mainGui.AddEdit("x250 y168 w145 h27", "q")
    row.interval := mainGui.AddEdit("x410 y168 w80 h27", "5")
    row.unit := mainGui.AddDropDownList("x500 y168 w140 Choose1", ["Seconds", "Milliseconds"])
    mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
    row.remove := mainGui.AddButton("x650 y168 w90 h25", "Remove")
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
            row.enabled.Visible := false
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
            row.enabled.Move(190, y, 50, 27)
            row.key.Move(250, y, 145, 27)
            row.interval.Move(410, y, 80, 27)
            row.unit.Move(500, y, 140, 27)
            row.remove.Move(650, y, 90, 27)
            row.enabled.Visible := true
            row.key.Visible := true
            row.interval.Visible := true
            row.unit.Visible := true
            row.remove.Visible := true
        } else {
            row.enabled.Visible := false
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
        if !row.enabled.Value
            continue
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
    enabledCount := 0
    seenKeys := Map()
    duplicateFound := false
    for index, row in macroRows {
        if !row.enabled.Value
            continue
        enabledCount += 1
        normalizedKey := StrLower(Trim(row.key.Value))
        if seenKeys.Has(normalizedKey)
            duplicateFound := true
        else
            seenKeys[normalizedKey] := index
    }
    if (enabledCount = 0) {
        MsgBox("Enable at least one ability before starting.", "Nothing enabled", "Icon!")
        return
    }
    if duplicateFound && (MsgBox("Two or more enabled abilities use the same key. Start anyway?", "Duplicate keybinds", "YesNo Icon!") = "No")
        return
    tickCount := 0
    tickText.Text := "Key presses: 0"
    running := true
    statusText.Text := "Status: RUNNING — enabled abilities active"
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
        if (row.enabled.Value && now >= row.nextTick) {
            SendInput(row.key.Value)
            tickCount += 1
            tickText.Text := "Key presses: " tickCount
            row.nextTick := now + row.intervalMs
        }
    }
}

SaveProfile(*) {
    global macroRows
    path := FileSelect("S16", A_ScriptDir, "Save TDS profile", "INI files (*.ini)", "TDS-profile.ini")
    if (path = "")
        return
    if !RegExMatch(path, "i)\.ini$")
        path .= ".ini"
    IniWrite(macroRows.Length, path, "Profile", "Count")
    for index, row in macroRows {
        section := "Ability" index
        IniWrite(row.key.Value, path, section, "Key")
        IniWrite(row.interval.Value, path, section, "Interval")
        IniWrite(row.unit.Text, path, section, "Unit")
        IniWrite(row.enabled.Value, path, section, "Enabled")
    }
    MsgBox("Profile saved successfully.", "TDS Macro Studio", "Iconi")
}

LoadProfile(*) {
    global macroRows, fieldScroll
    path := FileSelect("1", A_ScriptDir, "Load TDS profile", "INI files (*.ini)")
    if (path = "")
        return
    StopMacro()
    count := Integer(IniRead(path, "Profile", "Count", "0"))
    if (count < 1 || count > 8) {
        MsgBox("This profile has an invalid ability count.", "Unable to load profile", "Icon!")
        return
    }
    for _, oldRow in macroRows {
        oldRow.enabled.Visible := false
        oldRow.key.Visible := false
        oldRow.interval.Visible := false
        oldRow.unit.Visible := false
        oldRow.remove.Visible := false
    }
    macroRows := []
    fieldScroll := 0
    Loop count {
        AddField()
        row := macroRows[A_Index]
        section := "Ability" A_Index
        row.key.Value := IniRead(path, section, "Key", "q")
        row.interval.Value := IniRead(path, section, "Interval", "5")
        unitText := IniRead(path, section, "Unit", "Seconds")
        row.unit.Value := (unitText = "Milliseconds" ? 2 : 1)
        row.enabled.Value := Integer(IniRead(path, section, "Enabled", "1"))
    }
    RefreshLayout()
    MsgBox("Profile loaded successfully.", "TDS Macro Studio", "Iconi")
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

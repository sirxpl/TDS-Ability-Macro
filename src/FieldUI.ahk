; Controls and scrolling for the two independent sections.

AddCurrentField(*) {
    global sectionTabs
    if (sectionTabs.Value = 2)
        AddHoldField()
    else
        AddField()
}

AddField(*) {
    global macroRows, mainGui, sectionTabs
    if (macroRows.Length >= 8) {
        MsgBox("You can add up to 8 timed abilities.", "Field limit", "Icon!")
        return
    }
    sectionTabs.UseTab(1)
    row := {}
    mainGui.SetFont("s9 c202030", "Segoe UI")
    row.enabled := mainGui.AddCheckBox("x205 y196 w40 h27 Checked", "On")
    row.trigger := mainGui.AddEdit("x250 y196 w100 h27", "F1")
    row.key := mainGui.AddEdit("x360 y196 w100 h27", "q")
    row.interval := mainGui.AddEdit("x470 y196 w70 h27", "5")
    row.unit := mainGui.AddDropDownList("x550 y196 w105 Choose1", ["Seconds", "Milliseconds"])
    mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
    row.remove := mainGui.AddButton("x665 y196 w135 h27", "Remove")
    row.remove.OnEvent("Click", (*) => RemoveField(row, false))
    row.intervalMs := 5000
    row.nextTick := 0
    row.active := false
    row.hotkeyRegistered := false
    row.registeredTrigger := ""
    macroRows.Push(row)
    sectionTabs.UseTab()
    RefreshLayout(false)
}

AddHoldField(*) {
    global holdRows, mainGui, sectionTabs
    if (holdRows.Length >= 8) {
        MsgBox("You can add up to 8 hold-to-spam keys.", "Field limit", "Icon!")
        return
    }
    sectionTabs.UseTab(2)
    row := {}
    mainGui.SetFont("s9 c202030", "Segoe UI")
    row.enabled := mainGui.AddCheckBox("x205 y232 w40 h27 Checked", "On")
    row.key := mainGui.AddEdit("x250 y232 w170 h27", "q")
    row.interval := mainGui.AddEdit("x430 y232 w80 h27", "50")
    row.unit := mainGui.AddDropDownList("x520 y232 w135 Choose2", ["Seconds", "Milliseconds"])
    mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
    row.remove := mainGui.AddButton("x665 y232 w135 h27", "Remove")
    row.remove.OnEvent("Click", (*) => RemoveField(row, true))
    row.intervalMs := 50
    row.nextTick := 0
    holdRows.Push(row)
    sectionTabs.UseTab()
    RefreshLayout(true)
}

RemoveField(rowToRemove, isHold, *) {
    global macroRows, holdRows, running
    rows := isHold ? holdRows : macroRows
    if (rows.Length <= 1) {
        MsgBox("Keep at least one row in each section.", "Cannot remove", "Icon!")
        return
    }
    if (!isHold && running && rowToRemove.hotkeyRegistered) {
        try Hotkey(rowToRemove.registeredTrigger, "Off")
        rowToRemove.hotkeyRegistered := false
        rowToRemove.active := false
    }
    for index, row in rows {
        if (row = rowToRemove) {
            row.enabled.Visible := false
            if row.HasOwnProp("trigger")
                row.trigger.Visible := false
            row.key.Visible := false
            row.interval.Visible := false
            row.unit.Visible := false
            row.remove.Visible := false
            rows.RemoveAt(index)
            break
        }
    }
    RefreshLayout(isHold)
}

RefreshLayout(isHold := false) {
    global macroRows, holdRows, fieldScroll, holdScroll, visibleRows
    rows := isHold ? holdRows : macroRows
    scroll := isHold ? holdScroll : fieldScroll
    maxScroll := Max(0, rows.Length - visibleRows)
    scroll := Min(scroll, maxScroll)
    if isHold
        holdScroll := scroll
    else
        fieldScroll := scroll

    baseY := isHold ? 232 : 196
    for index, row in rows {
        slot := index - 1 - scroll
        if (slot >= 0 && slot < visibleRows) {
            y := baseY + slot * 35
            row.enabled.Move(205, y, 40, 27)
            if !isHold
                row.trigger.Move(250, y, 100, 27)
            row.key.Move(isHold ? 250 : 360, y, isHold ? 170 : 100, 27)
            row.interval.Move(isHold ? 430 : 470, y, isHold ? 80 : 70, 27)
            row.unit.Move(isHold ? 520 : 550, y, isHold ? 135 : 105, 27)
            row.remove.Move(665, y, 135, 27)
            row.enabled.Visible := true
            if !isHold
                row.trigger.Visible := true
            row.key.Visible := true
            row.interval.Visible := true
            row.unit.Visible := true
            row.remove.Visible := true
        } else {
            row.enabled.Visible := false
            if row.HasOwnProp("trigger")
                row.trigger.Visible := false
            row.key.Visible := false
            row.interval.Visible := false
            row.unit.Visible := false
            row.remove.Visible := false
        }
    }
}

ScrollCurrentFields(direction, *) {
    global sectionTabs, fieldScroll, holdScroll, macroRows, holdRows, visibleRows
    if (sectionTabs.Value = 2) {
        holdScroll := Max(0, Min(holdScroll + direction, Max(0, holdRows.Length - visibleRows)))
        RefreshLayout(true)
    } else {
        fieldScroll := Max(0, Min(fieldScroll + direction, Max(0, macroRows.Length - visibleRows)))
        RefreshLayout(false)
    }
}

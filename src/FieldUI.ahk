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
    row.key := mainGui.AddEdit("x250 y196 w170 h27", "q")
    row.interval := mainGui.AddEdit("x430 y196 w80 h27", "5")
    row.unit := mainGui.AddDropDownList("x520 y196 w135 Choose1", ["Seconds", "Milliseconds"])
    mainGui.SetFont("s9 cF0F0F0", "Segoe UI")
    row.remove := mainGui.AddButton("x665 y196 w135 h27", "Remove")
    row.remove.OnEvent("Click", (*) => RemoveField(row, false))
    row.intervalMs := 5000
    row.nextTick := 0
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
    global macroRows, holdRows
    rows := isHold ? holdRows : macroRows
    if (rows.Length <= 1) {
        MsgBox("Keep at least one row in each section.", "Cannot remove", "Icon!")
        return
    }
    for index, row in rows {
        if (row = rowToRemove) {
            row.enabled.Visible := false
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
            row.key.Move(250, y, 170, 27)
            row.interval.Move(430, y, 80, 27)
            row.unit.Move(520, y, 135, 27)
            row.remove.Move(665, y, 135, 27)
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

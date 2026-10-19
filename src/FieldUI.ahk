; Field controls, row layout, and scrolling.

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

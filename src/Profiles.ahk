; Save and load timed and hold-to-spam rows in one profile.

SaveProfile(*) {
    global macroRows, holdRows
    profileDir := A_ScriptDir "\profiles"
    DirCreate(profileDir)
    path := FileSelect("S16", profileDir "\TDS-profile.ini", "Save TDS profile", "INI files (*.ini)")
    if (path = "")
        return
    if !RegExMatch(path, "i)\.ini$")
        path .= ".ini"

    IniWrite(macroRows.Length, path, "Profile", "TimedCount")
    IniWrite(holdRows.Length, path, "Profile", "HoldCount")
    for index, row in macroRows
        WriteProfileRow(row, path, "Timed" index)
    for index, row in holdRows
        WriteProfileRow(row, path, "Hold" index)

    MsgBox("Profile saved successfully.", "TDS Macro Studio", "Iconi")
}

WriteProfileRow(row, path, section) {
    IniWrite(row.key.Value, path, section, "Key")
    IniWrite(row.interval.Value, path, section, "Interval")
    IniWrite(row.unit.Text, path, section, "Unit")
    IniWrite(row.enabled.Value, path, section, "Enabled")
}

LoadProfile(*) {
    global macroRows, holdRows, fieldScroll, holdScroll
    profileDir := A_ScriptDir "\profiles"
    DirCreate(profileDir)
    path := FileSelect("1", profileDir, "Load TDS profile", "INI files (*.ini)")
    if (path = "")
        return
    StopMacro()

    ; Support profiles created by the previous single-list version.
    timedCountText := IniRead(path, "Profile", "TimedCount", "")
    holdCountText := IniRead(path, "Profile", "HoldCount", "")
    if (timedCountText = "") {
        legacyCount := Integer(IniRead(path, "Profile", "Count", "0"))
        if (legacyCount < 1 || legacyCount > 8) {
            MsgBox("This profile has an invalid ability count.", "Unable to load profile", "Icon!")
            return
        }
        timedCount := 0
        holdCount := 0
        Loop legacyCount {
            section := "Ability" A_Index
            if (Integer(IniRead(path, section, "Hold", "0")) = 1)
                holdCount += 1
            else
                timedCount += 1
        }
    } else {
        timedCount := Integer(timedCountText)
        holdCount := Integer(holdCountText)
    }

    if (timedCount < 0 || timedCount > 8 || holdCount < 0 || holdCount > 8 || timedCount + holdCount < 1) {
        MsgBox("This profile has an invalid row count.", "Unable to load profile", "Icon!")
        return
    }

    for _, row in macroRows
        HideProfileRow(row)
    for _, row in holdRows
        HideProfileRow(row)
    macroRows := []
    holdRows := []
    fieldScroll := 0
    holdScroll := 0

    if (timedCountText = "") {
        timedIndex := 0
        holdIndex := 0
        Loop legacyCount {
            oldSection := "Ability" A_Index
            wasHold := Integer(IniRead(path, oldSection, "Hold", "0")) = 1
            if wasHold {
                holdIndex += 1
                AddHoldField()
                row := holdRows[holdIndex]
            } else {
                timedIndex += 1
                AddField()
                row := macroRows[timedIndex]
            }
            LoadProfileRow(row, path, oldSection)
        }
    } else {
        Loop timedCount {
            AddField()
            LoadProfileRow(macroRows[A_Index], path, "Timed" A_Index)
        }
        Loop holdCount {
            AddHoldField()
            LoadProfileRow(holdRows[A_Index], path, "Hold" A_Index)
        }
    }
    RefreshLayout(false)
    RefreshLayout(true)
    MsgBox("Profile loaded successfully.", "TDS Macro Studio", "Iconi")
}

LoadProfileRow(row, path, section) {
    row.key.Value := IniRead(path, section, "Key", "q")
    row.interval.Value := IniRead(path, section, "Interval", "5")
    unitText := IniRead(path, section, "Unit", "Seconds")
    row.unit.Value := (unitText = "Milliseconds" ? 2 : 1)
    row.enabled.Value := Integer(IniRead(path, section, "Enabled", "1"))
}

HideProfileRow(row) {
    row.enabled.Visible := false
    row.key.Visible := false
    row.interval.Visible := false
    row.unit.Visible := false
    row.remove.Visible := false
}

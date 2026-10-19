; Save and load macro profiles.

SaveProfile(*) {
    global macroRows
    profileDir := A_ScriptDir "\profiles"
    DirCreate(profileDir)
    path := FileSelect("S16", profileDir "\TDS-profile.ini", "Save TDS profile", "INI files (*.ini)")
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
    profileDir := A_ScriptDir "\profiles"
    DirCreate(profileDir)
    path := FileSelect("1", profileDir, "Load TDS profile", "INI files (*.ini)")
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

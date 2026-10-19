; Scheduling and key dispatch for timed abilities and hold-to-spam keys.

StartMacro(*) {
    global running, macroRows, holdRows, statusText, tickCount, tickText
    enabledCount := 0
    seenKeys := Map()
    duplicateFound := false

    for _, row in macroRows {
        if !row.enabled.Value
            continue
        if (Trim(row.key.Value) = "") {
            MsgBox("Timed ability: enter a key or SendInput sequence.", "Missing key", "Icon!")
            return
        }
        intervalMs := ValidateInterval(row, false)
        if (intervalMs = 0)
            return
        row.intervalMs := intervalMs
        row.nextTick := A_TickCount
        enabledCount += 1
        normalizedKey := "timed:" StrLower(Trim(row.key.Value))
        if seenKeys.Has(normalizedKey)
            duplicateFound := true
        else
            seenKeys[normalizedKey] := true
    }

    for _, row in holdRows {
        if !row.enabled.Value
            continue
        if (PhysicalKeyFor(row.key.Value) = "") {
            MsgBox("Hold-to-spam keys support letters, numbers, F1-F12, and standard named keys such as Space, Enter, and arrows.", "Unsupported hold key", "Icon!")
            return
        }
        intervalMs := ValidateInterval(row, true)
        if (intervalMs = 0)
            return
        row.intervalMs := intervalMs
        row.nextTick := A_TickCount
        enabledCount += 1
        normalizedKey := "hold:" StrLower(Trim(row.key.Value))
        if seenKeys.Has(normalizedKey)
            duplicateFound := true
        else
            seenKeys[normalizedKey] := true
    }

    if (enabledCount = 0) {
        MsgBox("Enable at least one timed ability or hold key before starting.", "Nothing enabled", "Icon!")
        return
    }
    if duplicateFound && (MsgBox("Two or more enabled rows use the same key in the same section. Start anyway?", "Duplicate keys", "YesNo Icon!") = "No")
        return

    tickCount := 0
    tickText.Text := "Key presses: 0"
    running := true
    statusText.Text := "Status: RUNNING — enabled actions active"
    SetTimer(ProcessMacros, 10)
}

ValidateInterval(row, isHold) {
    intervalText := Trim(row.interval.Value)
    if !RegExMatch(intervalText, "^\d+(?:\.\d+)?$") {
        MsgBox("Enter a valid interval number.", "Invalid interval", "Icon!")
        return 0
    }
    intervalValue := Float(intervalText)
    if (row.unit.Text = "Seconds") {
        if (intervalValue < 0.1 || intervalValue > 3600) {
            MsgBox("Seconds must be between 0.1 and 3600.", "Invalid interval", "Icon!")
            return 0
        }
        return Max(100, Round(intervalValue * 1000))
    }
    if (intervalValue < 10 || intervalValue > 3600000) {
        MsgBox("Milliseconds must be between 10 and 3600000.", "Invalid interval", "Icon!")
        return 0
    }
    return Round(intervalValue)
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
    global running, macroRows, holdRows, tickCount, tickText
    if !running
        return
    now := A_TickCount

    for _, row in macroRows {
        if !row.enabled.Value || now < row.nextTick
            continue
        SendInput(row.key.Value)
        tickCount += 1
        row.nextTick := now + row.intervalMs
    }

    for _, row in holdRows {
        if !row.enabled.Value
            continue
        physicalKey := PhysicalKeyFor(row.key.Value)
        if (physicalKey = "" || !GetKeyState(physicalKey, "P")) {
            row.nextTick := now
            continue
        }
        if (now < row.nextTick)
            continue
        SendInput("{" physicalKey "}")
        tickCount += 1
        row.nextTick := now + row.intervalMs
    }
    tickText.Text := "Key presses: " tickCount
}

PhysicalKeyFor(label) {
    label := Trim(label)
    lower := StrLower(label)
    if RegExMatch(lower, "^[a-z0-9]$")
        return lower
    if RegExMatch(label, "i)^F(?:[1-9]|1[0-2])$")
        return label
    static named := Map(
        "Space", "Space", "Enter", "Enter", "Tab", "Tab", "Escape", "Escape",
        "Backspace", "Backspace", "Delete", "Delete", "Insert", "Insert",
        "Home", "Home", "End", "End", "PgUp", "PgUp", "PgDn", "PgDn",
        "Up", "Up", "Down", "Down", "Left", "Left", "Right", "Right"
    )
    return named.Has(label) ? named[label] : ""
}

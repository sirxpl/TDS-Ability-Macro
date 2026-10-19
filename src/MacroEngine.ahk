; Scheduling and key dispatch for timed abilities and hold-to-spam keys.
; Timed rows are individually toggled by their configured trigger hotkeys.

StartMacro(*) {
    global running, macroRows, holdRows, statusText, tickCount, tickText
    enabledCount := 0
    seenTriggers := Map()

    for _, row in macroRows {
        row.active := false
        if !row.enabled.Value
            continue
        trigger := Trim(row.trigger.Value)
        if (trigger = "" || Trim(row.key.Value) = "") {
            MsgBox("Timed ability: enter both a trigger hotkey and an ability key / SendInput sequence.", "Missing input", "Icon!")
            return
        }
        intervalMs := ValidateInterval(row, false)
        if (intervalMs = 0)
            return
        normalizedTrigger := StrLower(trigger)
        if (normalizedTrigger = "f6" || normalizedTrigger = "f8") {
            MsgBox("F6 and F8 are reserved for Start/Stop and Exit. Choose another trigger hotkey.", "Reserved hotkey", "Icon!")
            return
        }
        if seenTriggers.Has(normalizedTrigger) {
            MsgBox("Each enabled timed ability needs a unique trigger hotkey. Duplicate: " trigger, "Duplicate trigger", "Icon!")
            return
        }
        seenTriggers[normalizedTrigger] := true
        row.intervalMs := intervalMs
        row.nextTick := 0
        enabledCount += 1
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
    }

    if (enabledCount = 0) {
        MsgBox("Enable at least one timed ability or hold key before starting.", "Nothing enabled", "Icon!")
        return
    }

    tickCount := 0
    tickText.Text := "Key presses: 0"
    running := true

    try {
        for _, row in macroRows {
            if !row.enabled.Value
                continue
            trigger := Trim(row.trigger.Value)
            callback := CreateTimedCallback(row)
            Hotkey(trigger, callback, "On")
            row.hotkeyRegistered := true
            row.registeredTrigger := trigger
            row.triggerCallback := callback
        }
    } catch as err {
        for _, row in macroRows {
            if row.hotkeyRegistered {
                try Hotkey(row.registeredTrigger, "Off")
                row.hotkeyRegistered := false
            }
        }
        running := false
        MsgBox("Couldn't register a trigger hotkey. Check its spelling and make sure it doesn't conflict with F6/F8 or another active hotkey.\`n\`n" err.Message, "Invalid trigger hotkey", "Icon!")
        return
    }

    statusText.Text := "Status: RUNNING — press a timed trigger to toggle its timer"
    SetTimer(ProcessMacros, 10)
}

CreateTimedCallback(row) {
    return (*) => ToggleTimedRow(row)
}

ToggleTimedRow(row) {
    global running, statusText
    if (!running || !row.enabled.Value)
        return
    row.active := !row.active
    row.nextTick := A_TickCount
    statusText.Text := "Status: RUNNING — " Trim(row.trigger.Value) (row.active ? " active" : " paused")
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
    global running, statusText, macroRows
    running := false
    SetTimer(ProcessMacros, 0)
    for _, row in macroRows {
        if row.hotkeyRegistered {
            try Hotkey(row.registeredTrigger, "Off")
            row.hotkeyRegistered := false
        }
        row.active := false
    }
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
        if (!row.enabled.Value || !row.active || now < row.nextTick)
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

; Macro scheduling, validation, and key dispatch.

StartMacro(*) {
    global running, macroRows, statusText, tickCount, tickText
    for index, row in macroRows {
        if !row.enabled.Value
            continue
        if (Trim(row.key.Value) = "") {
            MsgBox("Field " index ": type a key or SendInput sequence.", "Missing key", "Icon!")
            return
        }
        if row.hold.Value && (PhysicalKeyFor(row.key.Value) = "") {
            MsgBox("Field " index ": Hold mode supports letters, numbers, function keys, and standard named keys (Space, Enter, arrows, etc.). Turn Hold off to use symbols or SendInput sequences.", "Unsupported Hold key", "Icon!")
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
        row.nextTick := A_TickCount
    }
    enabledCount := 0
    seenKeys := Map()
    duplicateFound := false
    for index, row in macroRows {
        if !row.enabled.Value
            continue
        enabledCount += 1
        normalizedKey := StrLower(Trim(row.key.Value)) ":" row.hold.Value
        if seenKeys.Has(normalizedKey)
            duplicateFound := true
        else
            seenKeys[normalizedKey] := index
    }
    if (enabledCount = 0) {
        MsgBox("Enable at least one ability before starting.", "Nothing enabled", "Icon!")
        return
    }
    if duplicateFound && (MsgBox("Two or more enabled abilities use the same key and mode. Start anyway?", "Duplicate keybinds", "YesNo Icon!") = "No")
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
        if !row.enabled.Value
            continue
        if row.hold.Value {
            physicalKey := PhysicalKeyFor(row.key.Value)
            if (physicalKey = "" || !GetKeyState(physicalKey, "P")) {
                row.nextTick := now
                continue
            }
            if (now < row.nextTick)
                continue
            SendInput("{" physicalKey "}")
        } else {
            if (now < row.nextTick)
                continue
            SendInput(row.key.Value)
        }
        tickCount += 1
        tickText.Text := "Key presses: " tickCount
        row.nextTick := now + row.intervalMs
    }
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

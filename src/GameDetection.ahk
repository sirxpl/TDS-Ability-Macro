; Independent TDS game-window and optional image-template detection.
; Optional templates can be placed under:
;   pictures\detection\maps\<Map Name>.png
;   pictures\detection\modes\<Mode Name>.png
; Templates are searched only inside the visible Roblox client area. They work
; best when cropped from UI that is visible in the game and captured at the
; same window size. A match is remembered until Roblox closes or another
; matching template is found, so selection-screen templates can persist in-game.

tdsDetectionEnabled := true
tdsDetectedRobloxHwnd := 0
tdsDetectionState := "Waiting for Roblox"
tdsDetectedMap := "Unknown"
tdsDetectedMode := "Unknown"
tdsDetectedPlayers := "Unknown"
tdsAutoDetectedMap := "Unknown"
tdsAutoDetectedMode := "Unknown"
tdsManualSetupEnabled := false
tdsManualMap := ""
tdsManualMode := ""
tdsManualPlayers := ""
tdsElapsedRunning := false
tdsElapsedStartTick := 0
tdsElapsedAccumulatedMs := 0
tdsElapsedLastRpcMinute := -1
tdsElapsedDisplay := "00:00:00"

StartTDSGameDetection() {
    SetTimer(TDSGameDetectionTick, 3000)
    SetTimer(TDSUpdateElapsedTime, 1000)
    TDSGameDetectionTick()
    TDSUpdateElapsedTime()
}

StopTDSGameDetection(*) {
    SetTimer(TDSGameDetectionTick, 0)
    SetTimer(TDSUpdateElapsedTime, 0)
}

TDSGameDetectionTick(*) {
    global tdsDetectedRobloxHwnd, tdsDetectionState, tdsDetectedMap, tdsDetectedMode, tdsDetectedPlayers
    global tdsAutoDetectedMap, tdsAutoDetectedMode, tdsManualSetupEnabled, tdsManualMap, tdsManualMode, tdsManualPlayers
    global tdsDetectionStatusText, tdsDetectedMapText, tdsDetectedModeText, tdsDetectedPlayersText

    foundHwnd := 0
    try {
        for hwnd in WinGetList("ahk_exe RobloxPlayerBeta.exe") {
            if DllCall("IsWindowVisible", "Ptr", hwnd, "Int") {
                foundHwnd := hwnd
                break
            }
        }
    } catch {
        foundHwnd := 0
    }

    oldState := tdsDetectionState
    oldMap := tdsDetectedMap
    oldMode := tdsDetectedMode
    oldPlayers := tdsDetectedPlayers
    tdsDetectedRobloxHwnd := foundHwnd

    if foundHwnd {
        tdsDetectionState := "Roblox detected"
        try {
            if (WinGetMinMax("ahk_id " foundHwnd) = -1) {
                ; Keep the last known map/mode while the game is minimized.
                tdsDetectionState := "Roblox detected (minimized)"
            } else {
                WinGetClientPos(&winX, &winY, &winW, &winH, "ahk_id " foundHwnd)
                if (winW > 0 && winH > 0) {
                    detectedMap := TDSFindVisualTemplate("maps", winX, winY, winX + winW - 1, winY + winH - 1)
                    detectedMode := TDSFindVisualTemplate("modes", winX, winY, winX + winW - 1, winY + winH - 1)

                    ; Do not erase a known result just because its UI is no longer visible.
                    if (detectedMap != "Unknown")
                        tdsAutoDetectedMap := detectedMap
                    if (detectedMode != "Unknown")
                        tdsAutoDetectedMode := detectedMode
                }
            }
        } catch {
            ; Keep the last known map/mode if window geometry temporarily fails.
        }
    } else {
        tdsDetectionState := "Waiting for Roblox"
        tdsAutoDetectedMap := "Unknown"
        tdsAutoDetectedMode := "Unknown"
    }

    ; Manual setup overrides automatic map/mode results when enabled.
    tdsDetectedMap := tdsManualSetupEnabled && Trim(tdsManualMap) != "" ? Trim(tdsManualMap) : tdsAutoDetectedMap
    tdsDetectedMode := tdsManualSetupEnabled && Trim(tdsManualMode) != "" ? Trim(tdsManualMode) : tdsAutoDetectedMode
    tdsDetectedPlayers := tdsManualSetupEnabled && Trim(tdsManualPlayers) != "" ? Trim(tdsManualPlayers) : "Unknown"

    if IsSet(tdsDetectionStatusText) {
        tdsDetectionStatusText.Text := "Status: " tdsDetectionState
        tdsDetectedMapText.Text := "Map: " tdsDetectedMap
        tdsDetectedModeText.Text := "Gamemode: " tdsDetectedMode
        tdsDetectedPlayersText.Text := "Players: " tdsDetectedPlayers
    }

    ; Refresh RPC when the game, map, or mode status changes.
    if (oldState != tdsDetectionState || oldMap != tdsDetectedMap || oldMode != tdsDetectedMode || oldPlayers != tdsDetectedPlayers) {
        try DiscordRPCSetActivity()
    }
}

TDSFindVisualTemplate(category, left, top, right, bottom) {
    folder := A_ScriptDir "\pictures\detection\" category
    if !DirExist(folder)
        return "Unknown"

    ; Template filenames become displayed labels, e.g. "Crossroads.png".
    Loop Files, folder "\*.png", "F" {
        try {
            foundX := 0
            foundY := 0
            if ImageSearch(&foundX, &foundY, left, top, right, bottom, "*30 " A_LoopFileFullPath)
                return RegExReplace(A_LoopFileName, "\.[^.]+$")
        } catch {
            ; Invalid or incompatible templates are skipped without stopping the macro.
        }
    }
    return "Unknown"
}

SaveManualGameSetup(*) {
    global tdsManualSetupCheck, tdsManualMapEdit, tdsManualModeEdit, tdsManualPlayersEdit
    global tdsManualSetupEnabled, tdsManualMap, tdsManualMode, tdsManualPlayers
    global tdsDetectionStatusText
    nextManualEnabled := !!tdsManualSetupCheck.Value
    nextManualMap := Trim(tdsManualMapEdit.Value)
    nextManualMode := Trim(tdsManualModeEdit.Value)
    nextManualPlayers := Trim(tdsManualPlayersEdit.Value)

    if (nextManualPlayers != "" && !RegExMatch(nextManualPlayers, "^([1-4])$")) {
        tdsDetectionStatusText.Text := "Status: Players must be a number from 1 to 4."
        return
    }

    tdsManualSetupEnabled := nextManualEnabled
    tdsManualMap := nextManualMap
    tdsManualMode := nextManualMode
    tdsManualPlayers := nextManualPlayers
    TDSGameDetectionTick()
    if tdsManualSetupEnabled
        tdsDetectionStatusText.Text := "Status: Manual setup enabled"
}

ToggleTDSMatchTimer(*) {
    global tdsElapsedRunning, tdsElapsedStartTick
    global tdsElapsedButton, tdsDetectionStatusText

    if tdsElapsedRunning {
        tdsElapsedRunning := false
        tdsElapsedButton.Text := "▶ Start Timer"
        tdsDetectionStatusText.Text := "Status: Elapsed timer paused"
    } else {
        tdsElapsedRunning := true
        tdsElapsedStartTick := A_TickCount
        tdsElapsedButton.Text := "Ⅱ Pause Timer"
        tdsDetectionStatusText.Text := "Status: Elapsed timer running"
    }
    TDSUpdateElapsedTime()
}

ResetTDSMatchTimer(*) {
    global tdsElapsedRunning, tdsElapsedStartTick, tdsElapsedAccumulatedMs
    global tdsElapsedButton, tdsDetectionStatusText
    tdsElapsedRunning := false
    tdsElapsedStartTick := 0
    tdsElapsedAccumulatedMs := 0
    tdsElapsedButton.Text := "▶ Start Timer"
    tdsDetectionStatusText.Text := "Status: Elapsed timer reset"
    TDSUpdateElapsedTime(true)
}

TDSUpdateElapsedTime(forceRpc := false) {
    global tdsElapsedRunning, tdsElapsedStartTick, tdsElapsedAccumulatedMs
    global tdsElapsedLastRpcMinute, tdsElapsedDisplay, tdsElapsedText
    elapsedMs := tdsElapsedAccumulatedMs
    if tdsElapsedRunning
        elapsedMs += A_TickCount - tdsElapsedStartTick

    totalSeconds := Floor(elapsedMs / 1000)
    hours := Floor(totalSeconds / 3600)
    minutes := Floor(Mod(totalSeconds, 3600) / 60)
    seconds := Mod(totalSeconds, 60)
    tdsElapsedDisplay := Format("{:02}:{:02}:{:02}", hours, minutes, seconds)

    if IsSet(tdsElapsedText)
        tdsElapsedText.Text := "Elapsed Time: " tdsElapsedDisplay

    rpcMinute := Floor(totalSeconds / 60)
    if (forceRpc || rpcMinute != tdsElapsedLastRpcMinute) {
        tdsElapsedLastRpcMinute := rpcMinute
        try DiscordRPCSetActivity()
    }
}

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

StartTDSGameDetection() {
    SetTimer(TDSGameDetectionTick, 3000)
    TDSGameDetectionTick()
}

StopTDSGameDetection(*) {
    SetTimer(TDSGameDetectionTick, 0)
}

TDSGameDetectionTick(*) {
    global tdsDetectedRobloxHwnd, tdsDetectionState, tdsDetectedMap, tdsDetectedMode
    global tdsDetectionStatusText, tdsDetectedMapText, tdsDetectedModeText

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
                        tdsDetectedMap := detectedMap
                    if (detectedMode != "Unknown")
                        tdsDetectedMode := detectedMode
                }
            }
        } catch {
            ; Keep the last known map/mode if window geometry temporarily fails.
        }
    } else {
        tdsDetectionState := "Waiting for Roblox"
        tdsDetectedMap := "Unknown"
        tdsDetectedMode := "Unknown"
    }

    if IsSet(tdsDetectionStatusText) {
        tdsDetectionStatusText.Text := "Status: " tdsDetectionState
        tdsDetectedMapText.Text := "Map: " tdsDetectedMap
        tdsDetectedModeText.Text := "Gamemode: " tdsDetectedMode
    }

    ; Refresh RPC when the game, map, or mode status changes.
    if (oldState != tdsDetectionState || oldMap != tdsDetectedMap || oldMode != tdsDetectedMode) {
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

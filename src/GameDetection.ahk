; Independent TDS game-window and optional image-template detection.
; Add your own cropped reference PNGs under:
;   pictures\detection\maps\<Map Name>.png
;   pictures\detection\modes\<Mode Name>.png
; Templates are searched only inside the visible Roblox window. Matching is
; resolution-sensitive; capture templates at the same window size when possible.
; No map/mode is guessed when a template cannot be matched.

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
            if (WinGetMinMax("ahk_id " foundHwnd) != -1) {
                WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " foundHwnd)
                if (winW > 0 && winH > 0) {
                    tdsDetectedMap := TDSFindVisualTemplate("maps", winX, winY, winX + winW - 1, winY + winH - 1)
                    tdsDetectedMode := TDSFindVisualTemplate("modes", winX, winY, winX + winW - 1, winY + winH - 1)
                } else {
                    tdsDetectedMap := "Unknown"
                    tdsDetectedMode := "Unknown"
                }
            } else {
                tdsDetectedMap := "Unknown"
                tdsDetectedMode := "Unknown"
                tdsDetectionState := "Roblox detected (minimized)"
            }
        } catch {
            tdsDetectedMap := "Unknown"
            tdsDetectedMode := "Unknown"
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

    ; Template filenames become the displayed labels, e.g. "Crossroads.png".
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

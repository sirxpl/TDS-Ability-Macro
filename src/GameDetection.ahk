; TDS game-window detection for Discord Rich Presence.
; This first pass detects the Roblox client window only. Map/mode remain Unknown
; until a reliable OCR or image-template recognizer is available.

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
    global tdsDetectedRobloxHwnd, tdsDetectionState
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
    tdsDetectedRobloxHwnd := foundHwnd
    if foundHwnd
        tdsDetectionState := "Roblox detected — map/mode not identified yet"
    else
        tdsDetectionState := "Waiting for Roblox"

    if IsSet(tdsDetectionStatusText) {
        tdsDetectionStatusText.Text := "Status: " tdsDetectionState
        tdsDetectedMapText.Text := "Map: " tdsDetectedMap
        tdsDetectedModeText.Text := "Gamemode: " tdsDetectedMode
    }

    ; Refresh presence promptly when Roblox appears or closes.
    if (oldState != tdsDetectionState) {
        try DiscordRPCSetActivity()
    }
}

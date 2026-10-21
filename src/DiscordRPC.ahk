; Optional Discord Rich Presence for TDS Macro Studio.
; Uses Roblox's public thumbnail endpoint for the current TDS game icon.
; Configure ApplicationId in discord-rpc.ini. Discord Desktop must be running.

discordRPCHandle := 0
discordRPCApplicationId := ""
discordRPCEnabled := false
discordRPCGameIconUrl := ""
discordRPCIconLastChecked := 0
discordRPCPlaceId := "3260590327" ; TDS game place ID

StartDiscordPresence() {
    global discordRPCApplicationId, discordRPCEnabled
    configPath := A_ScriptDir "\discord-rpc.ini"
    if !FileExist(configPath)
        IniWrite("", configPath, "DiscordRPC", "ApplicationId")

    discordRPCApplicationId := Trim(IniRead(configPath, "DiscordRPC", "ApplicationId", ""))
    if !RegExMatch(discordRPCApplicationId, "^\d{15,22}$")
        return

    discordRPCEnabled := true
    DiscordRPCRefreshGameIcon(true)
    DiscordRPCMaintain()
    SetTimer(DiscordRPCMaintain, 15000)
}

DiscordRPCMaintain(*) {
    global discordRPCHandle, discordRPCEnabled
    if !discordRPCEnabled
        return

    ; Check Roblox's icon endpoint every 15 minutes; keep the previous URL if it fails.
    DiscordRPCRefreshGameIcon()
    if !discordRPCHandle {
        DiscordRPCConnect()
        return
    }

    if !DiscordRPCSetActivity() {
        DiscordRPCClose()
        DiscordRPCConnect()
    }
}

DiscordRPCRefreshGameIcon(force := false) {
    global discordRPCGameIconUrl, discordRPCIconLastChecked, discordRPCPlaceId
    if (!force && A_TickCount - discordRPCIconLastChecked < 900000)
        return discordRPCGameIconUrl
    discordRPCIconLastChecked := A_TickCount

    try {
        request := ComObject("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(2500, 2500, 3500, 3500)
        url := "https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" discordRPCPlaceId "&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false"
        request.Open("GET", url, false)
        request.SetRequestHeader("User-Agent", "TDS-Macro-Studio")
        request.Send()
        if (request.Status != 200)
            return discordRPCGameIconUrl

        body := request.ResponseText
        if RegExMatch(body, '"imageUrl"\s*:\s*"([^"]+)"', &match) {
            newUrl := StrReplace(match[1], "\/", "/")
            if InStr(newUrl, "https://") = 1
                discordRPCGameIconUrl := newUrl
        }
    } catch {
        ; Network/API failure is non-fatal; retain the last known good URL.
    }
    return discordRPCGameIconUrl
}

DiscordRPCConnect() {
    global discordRPCHandle, discordRPCApplicationId
    if !discordRPCApplicationId
        return false

    Loop 10 {
        pipePath := "\\\\.\\pipe\\discord-ipc-" (A_Index - 1)
        handle := DllCall("CreateFileW", "Str", pipePath, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        if (handle != -1 && handle != 0) {
            discordRPCHandle := handle
            if !DiscordRPCWritePacket(0, '{"v":1,"client_id":"' discordRPCApplicationId '"}') {
                DiscordRPCClose()
                continue
            }
            Sleep(150)
            if DiscordRPCSetActivity()
                return true
            DiscordRPCClose()
        }
    }
    return false
}

DiscordRPCSetActivity() {
    global discordRPCApplicationId, discordRPCGameIconUrl
    if !discordRPCApplicationId
        return false

    activity := '"type":0,"details":"Tower Defense Simulator","state":"TDS Macro Studio Open"'
    if (discordRPCGameIconUrl != "") {
        ; Discord's media proxy URL form allows a public HTTPS image URL as an activity asset.
        externalImage := "mp:external/" DiscordRPCUrlEncode(discordRPCGameIconUrl) "/" StrReplace(StrReplace(discordRPCGameIconUrl, "https://", "https/"), "http://", "http/")
        activity .= ',"assets":{"large_image":"' DiscordRPCJsonEscape(externalImage) '","large_text":"Tower Defense Simulator"}'
    }
    payload := '{"cmd":"SET_ACTIVITY","args":{"pid":' DllCall("GetCurrentProcessId", "UInt") ',"activity":{' activity '} },"nonce":"' A_TickCount '"}'
    return DiscordRPCWritePacket(1, payload)
}

DiscordRPCUrlEncode(url) {
    ; Encode the source URL for Discord's mp:external asset key.
    encoded := ""
    bytes := Buffer(StrPut(url, "UTF-8"), 0)
    StrPut(url, bytes, "UTF-8")
    Loop bytes.Size - 1 {
        b := NumGet(bytes, A_Index - 1, "UChar")
        ch := Chr(b)
        if ((b >= 0x30 && b <= 0x39) || (b >= 0x41 && b <= 0x5A) || (b >= 0x61 && b <= 0x7A) || InStr("-_.~", ch))
            encoded .= ch
        else
            encoded .= "%" Format("{:02X}", b)
    }
    return encoded
}

DiscordRPCJsonEscape(value) {
    value := StrReplace(value, "\\", "\\\\")
    value := StrReplace(value, '"', '\\"')
    return value
}

DiscordRPCWritePacket(opcode, payload) {
    global discordRPCHandle
    if !discordRPCHandle
        return false

    payloadBytes := StrPut(payload, "UTF-8") - 1
    payloadBuffer := Buffer(payloadBytes + 1, 0)
    StrPut(payload, payloadBuffer, "UTF-8")
    packet := Buffer(8 + payloadBytes, 0)
    NumPut("UInt", opcode, packet, 0)
    NumPut("UInt", payloadBytes, packet, 4)
    if payloadBytes
        DllCall("RtlMoveMemory", "Ptr", packet.Ptr + 8, "Ptr", payloadBuffer.Ptr, "UPtr", payloadBytes)

    written := 0
    ok := DllCall("WriteFile", "Ptr", discordRPCHandle, "Ptr", packet.Ptr, "UInt", packet.Size, "UInt*", &written, "Ptr", 0, "Int")
    return ok && written = packet.Size
}

DiscordRPCClose() {
    global discordRPCHandle
    if discordRPCHandle {
        try DiscordRPCWritePacket(1, '{"cmd":"SET_ACTIVITY","args":{"pid":' DllCall("GetCurrentProcessId", "UInt") ',"activity":null},"nonce":"clear-' A_TickCount '"}')
        DllCall("CloseHandle", "Ptr", discordRPCHandle)
        discordRPCHandle := 0
    }
}

StopDiscordPresence(*) {
    global discordRPCEnabled
    SetTimer(DiscordRPCMaintain, 0)
    DiscordRPCClose()
    discordRPCEnabled := false
}

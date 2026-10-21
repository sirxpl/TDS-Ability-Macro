; Optional Discord Rich Presence for TDS Macro Studio.
; Configure ApplicationId in discord-rpc.ini using your Discord Developer Portal app ID.
; The Discord desktop client must be running. Failure to connect is non-fatal.

discordRPCHandle := 0
discordRPCApplicationId := ""
discordRPCEnabled := false

StartDiscordPresence() {
    global discordRPCApplicationId, discordRPCEnabled
    configPath := A_ScriptDir "\discord-rpc.ini"
    if !FileExist(configPath)
        IniWrite("", configPath, "DiscordRPC", "ApplicationId")

    discordRPCApplicationId := Trim(IniRead(configPath, "DiscordRPC", "ApplicationId", ""))
    if !RegExMatch(discordRPCApplicationId, "^\d{15,22}$")
        return

    discordRPCEnabled := true
    DiscordRPCMaintain()
    SetTimer(DiscordRPCMaintain, 15000)
}

DiscordRPCMaintain(*) {
    global discordRPCHandle, discordRPCApplicationId, discordRPCEnabled
    if !discordRPCEnabled
        return

    if !discordRPCHandle {
        DiscordRPCConnect()
        return
    }

    ; Refresh periodically so a closed/restarted Discord client is detected.
    if !DiscordRPCSetActivity() {
        DiscordRPCClose()
        DiscordRPCConnect()
    }
}

DiscordRPCConnect() {
    global discordRPCHandle, discordRPCApplicationId
    if !discordRPCApplicationId
        return false

    Loop 10 {
            pipePath := "\\.\pipe\discord-ipc-" (A_Index - 1)
        handle := DllCall("CreateFileW", "Str", pipePath, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        if (handle != -1 && handle != 0) {
            discordRPCHandle := handle
            if !DiscordRPCWritePacket(0, '{"v":1,"client_id":"' discordRPCApplicationId '"}') {
                DiscordRPCClose()
                continue
            }
            ; Give the client a moment to process the handshake before activity.
            Sleep(150)
            if DiscordRPCSetActivity()
                return true
            DiscordRPCClose()
        }
    }
    return false
}

DiscordRPCSetActivity() {
    global discordRPCApplicationId
    if !discordRPCApplicationId
        return false

    payload := '{"cmd":"SET_ACTIVITY","args":{"pid":' DllCall("GetCurrentProcessId", "UInt") ',"activity":{"type":0,"details":"Using TDS Macro Studio","state":"Macro Studio Open"}},"nonce":"' A_TickCount '"}'
    return DiscordRPCWritePacket(1, payload)
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
        ; Clear the activity before closing when the client is still connected.
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

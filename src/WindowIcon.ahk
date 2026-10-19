; Runtime window-icon uploader for TDS Macro Studio.
; Supports ICO directly and PNG/JPG/JPEG/BMP through Windows GDI+.
; This changes only the current window icon; it does not modify the compiled EXE.

BrowseWindowIcon(*) {
    selectedFile := FileSelect(1, , "Choose an image for the app window icon", "Icon and image files (*.ico;*.png;*.jpg;*.jpeg;*.bmp)")
    if selectedFile != ""
        ApplyWindowIconFile(selectedFile)
}

ApplyWindowIconFile(path) {
    global mainGui, currentWindowIcon, iconStatusText

    if !FileExist(path) {
        SetIconStatus("File not found.")
        return
    }

    SplitPath(path, , , &extension)
    extension := StrLower(extension)
    if !InStr("|ico|png|jpg|jpeg|bmp|", "|" extension "|") {
        SetIconStatus("Use an ICO, PNG, JPG, JPEG, or BMP image.")
        return
    }

    hIcon := 0
    if extension = "ico" {
        try hIcon := LoadPicture(path, "Icon1")
        catch {
            SetIconStatus("Could not load that ICO file.")
            return
        }
    } else {
        hIcon := CreateIconFromImage(path)
    }

    if !hIcon {
        SetIconStatus("Could not load image. Try another file.")
        return
    }

    ; WM_SETICON: wParam 0 = small/title-bar icon, 1 = large icon.
    SendMessage(0x80, 0, hIcon, , "ahk_id " mainGui.Hwnd)
    SendMessage(0x80, 1, hIcon, , "ahk_id " mainGui.Hwnd)

    oldIcon := currentWindowIcon
    currentWindowIcon := hIcon
    if oldIcon
        DllCall("DestroyIcon", "Ptr", oldIcon)

    SplitPath(path, &fileName)
    SetIconStatus("Window icon changed to: " fileName)
}

CreateIconFromImage(path) {
    ; Start GDI+ for this conversion. The generated HICON remains valid after shutdown.
    si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
    NumPut("UInt", 1, si, 0)
    token := 0
    if DllCall("gdiplusGdiplusStartup", "Ptr*", &token, "Ptr", si, "Ptr", 0, "UInt") != 0
        return 0

    bitmap := 0
    hIcon := 0
    try {
        if DllCall("gdiplusGdipCreateBitmapFromFile", "WStr", path, "Ptr*", &bitmap, "UInt") = 0 {
            if DllCall("gdiplusGdipCreateHICONFromBitmap", "Ptr", bitmap, "Ptr*", &hIcon, "UInt") != 0
                hIcon := 0
            DllCall("gdiplusGdipDisposeImage", "Ptr", bitmap, "UInt")
        }
    } finally {
        DllCall("gdiplusGdiplusShutdown", "Ptr", token)
    }
    return hIcon
}

SetIconStatus(message) {
    global iconStatusText
    if IsSet(iconStatusText)
        iconStatusText.Text := message
}

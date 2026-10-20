; Embedded, always-on-top Google Docs / Sheets / Slides strategy viewer.
; Uses Microsoft's WebView2 control through the thqby/ahk2_lib AutoHotkey v2 wrapper.
; WebView2Loader.dll must be placed under lib\64bit or lib\32bit for the script architecture.

strategyGui := 0
strategyUrlEdit := 0
strategyStatusText := 0
strategyWebHost := 0
strategyWebController := 0
strategyWebCore := 0
strategyWebReady := false
strategyPendingUrl := ""

PinStrategyFromMain(*) {
    global strategyLinkEdit
    ShowStrategyWindow(Trim(strategyLinkEdit.Value))
}

ShowStrategyWindow(initialUrl := "") {
    global strategyGui, strategyUrlEdit, strategyStatusText, strategyWebHost
    global strategyWebController, strategyWebCore, strategyWebReady, strategyPendingUrl

    savedUrl := ""
    try savedUrl := IniRead(A_ScriptDir "\strategy.ini", "Strategy", "GoogleDocsUrl", "")
    if (initialUrl = "")
        initialUrl := savedUrl

    if IsObject(strategyGui) {
        try strategyGui.Show()
        if (initialUrl != "")
            strategyUrlEdit.Value := initialUrl
        if (NormalizeGoogleDocsPreviewUrl(initialUrl) != "")
            LoadStrategyPreview()
        return
    }

    strategyGui := Gui("+AlwaysOnTop +Resize +MinSize720x440", "Pinned Google Docs Strategy")
    strategyGui.BackColor := "1E1E2E"
    strategyGui.MarginX := 16
    strategyGui.MarginY := 12
    strategyGui.SetFont("s11 cB4Befe Bold", "Segoe UI")
    strategyGui.AddText("x16 y12 w850 h26", "PINNED STRATEGY")
    strategyGui.SetFont("s9 cB8C0D9", "Segoe UI")
    strategyGui.AddText("x16 y40 w850 h20", "Paste a Google Docs, Sheets, or Slides link. The preview is displayed inside this window.")
    strategyUrlEdit := strategyGui.AddEdit("x16 y66 w540 h28", initialUrl)
    loadButton := strategyGui.AddButton("x566 y64 w112 h32", "Load Preview")
    saveButton := strategyGui.AddButton("x686 y64 w92 h32", "Save Link")
    browserButton := strategyGui.AddButton("x786 y64 w112 h32", "Open Browser")
    strategyStatusText := strategyGui.AddText("x16 y104 w880 h22", "WebView2 preview will appear below. Google sharing permissions still apply.")
    strategyWebHost := strategyGui.AddText("x16 y132 w880 h470 Border", "")
    loadButton.OnEvent("Click", LoadStrategyPreview)
    saveButton.OnEvent("Click", SaveStrategyLink)
    browserButton.OnEvent("Click", OpenStrategyInBrowser)
    strategyGui.OnEvent("Size", StrategyWindowResized)
    strategyGui.OnEvent("Close", (*) => strategyGui.Hide())

    strategyGui.Show("w920 h650")

    strategyWebReady := false
    strategyWebController := 0
    strategyWebCore := 0
    strategyPendingUrl := NormalizeGoogleDocsPreviewUrl(initialUrl)

    loaderPath := A_ScriptDir "\lib\" (A_PtrSize = 8 ? "64bit" : "32bit") "\WebView2Loader.dll"
    if !FileExist(loaderPath) {
        strategyStatusText.Text := "WebView2 loader is missing. See README for setup; browser fallback is available."
        return
    }

    try {
        dataDir := A_AppData "\TDSMacroStudio\WebView2"
        if !DirExist(dataDir)
            DirCreate(dataDir)
        strategyStatusText.Text := "Starting embedded browser..."
        webViewPromise := WebView2.CreateControllerAsync(strategyWebHost.Hwnd, 0, dataDir, "", loaderPath)
        webViewPromise.then((controller) => StrategyWebViewReady(controller))
        webViewPromise.catch((err) => StrategyWebViewFailed(err))
    } catch as err {
        StrategyWebViewFailed(err)
    }
}

StrategyWebViewReady(controller) {
    global strategyWebController, strategyWebCore, strategyWebReady, strategyStatusText, strategyPendingUrl
    strategyWebController := controller
    strategyWebCore := controller.CoreWebView2
    strategyWebReady := true
    controller.Fill()
    strategyStatusText.Text := "Embedded preview ready. Some Google documents may require a published or share-enabled preview."
    if (strategyPendingUrl != "")
        strategyWebCore.Navigate(strategyPendingUrl)
}

StrategyWebViewFailed(err) {
    global strategyStatusText
    strategyStatusText.Text := "WebView2 could not start. Check the WebView2 Runtime and loader setup."
    try OutputDebug("TDS Macro Studio WebView2 error: " err.Message)
}

StrategyWindowResized(guiObj, minMax, width, height) {
    global strategyWebHost, strategyWebController
    if (minMax = -1)
        return
    try strategyWebHost.Move(16, 132, Max(200, width - 32), Max(150, height - 152))
    try strategyWebController.Fill()
}

NormalizeGoogleDocsPreviewUrl(url) {
    url := Trim(url)
    if !RegExMatch(url, "^https?://docs\.google\.com/(document|spreadsheets|presentation)/d/([A-Za-z0-9_-]+)(?:/[^?#]*)?(?:[?#].*)?$", &match)
        return ""
    return "https://docs.google.com/" match[1] "/d/" match[2] "/preview"
}

LoadStrategyPreview(*) {
    global strategyUrlEdit, strategyStatusText, strategyWebCore, strategyWebReady, strategyPendingUrl
    previewUrl := NormalizeGoogleDocsPreviewUrl(strategyUrlEdit.Value)
    if (previewUrl = "") {
        strategyStatusText.Text := "Paste a valid Google Docs, Sheets, or Slides URL."
        MsgBox("Paste a Google Docs, Sheets, or Slides link from docs.google.com.", "Invalid strategy link", "Icon!")
        return
    }
    strategyPendingUrl := previewUrl
    strategyUrlEdit.Value := previewUrl
    if !strategyWebReady || !IsObject(strategyWebCore) {
        strategyStatusText.Text := "Preview link is ready, but the embedded browser is not available. See README for setup."
        return
    }
    try {
        strategyWebCore.Navigate(previewUrl)
        strategyStatusText.Text := "Loading strategy preview..."
        SaveStrategyLink()
    } catch as err {
        strategyStatusText.Text := "Couldn't load the preview. Try Open Browser instead."
        MsgBox("Unable to load the embedded preview." Chr(10) Chr(10) err.Message, "Preview failed", "Icon!")
    }
}

OpenStrategyInBrowser(*) {
    global strategyUrlEdit, strategyStatusText
    previewUrl := NormalizeGoogleDocsPreviewUrl(strategyUrlEdit.Value)
    if (previewUrl = "") {
        strategyStatusText.Text := "Paste a valid Google Docs, Sheets, or Slides URL first."
        return
    }
    try {
        Run(previewUrl)
        strategyStatusText.Text := "Preview opened in your default browser."
    } catch as err {
        strategyStatusText.Text := "Could not open the preview in your browser."
        MsgBox("Unable to open the preview link." Chr(10) Chr(10) err.Message, "Preview failed", "Icon!")
    }
}

SaveStrategyLink(*) {
    global strategyUrlEdit, strategyStatusText
    previewUrl := NormalizeGoogleDocsPreviewUrl(strategyUrlEdit.Value)
    if (previewUrl = "") {
        strategyStatusText.Text := "Paste a valid Google Docs, Sheets, or Slides URL before saving."
        MsgBox("Paste a valid Google Docs, Sheets, or Slides URL before saving.", "Invalid strategy link", "Icon!")
        return
    }
    try {
        IniWrite(previewUrl, A_ScriptDir "\strategy.ini", "Strategy", "GoogleDocsUrl")
        strategyUrlEdit.Value := previewUrl
        strategyStatusText.Text := "Saved. Your preview link will be remembered next time."
    } catch as err {
        strategyStatusText.Text := "Couldn't save the link. Check folder permissions."
        MsgBox("Unable to save the strategy link." Chr(10) Chr(10) err.Message, "Save failed", "Icon!")
    }
}

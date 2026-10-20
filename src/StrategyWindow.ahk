; Pinned Google Docs strategy helper.
; The pinned helper stays on top. Google Docs content opens in the default browser
; because the project does not yet bundle an embedded WebView2 runtime wrapper.
strategyGui := 0
strategyUrlEdit := 0
strategyStatusText := 0

PinStrategyFromMain(*) {
    global strategyLinkEdit
    ShowStrategyWindow(Trim(strategyLinkEdit.Value))
}

ShowStrategyWindow(initialUrl := "") {
    global strategyGui, strategyUrlEdit, strategyStatusText
    savedUrl := ""
    try savedUrl := IniRead(A_ScriptDir "\strategy.ini", "Strategy", "GoogleDocsUrl", "")
    if (initialUrl = "")
        initialUrl := savedUrl

    if IsObject(strategyGui) {
        try strategyGui.Destroy()
    }

    strategyGui := Gui("+AlwaysOnTop +Resize", "Pinned Google Docs Strategy")
    strategyGui.BackColor := "1E1E2E"
    strategyGui.SetFont("s11 cB4Befe Bold", "Segoe UI")
    strategyGui.AddText("x16 y14 w480 h26", "PINNED STRATEGY")
    strategyGui.SetFont("s9 cB8C0D9", "Segoe UI")
    strategyGui.AddText("x16 y45 w480 h34", "Paste a Google Docs, Sheets, or Slides link. Preview opens read-only; editing links are converted to /preview.")
    strategyUrlEdit := strategyGui.AddEdit("x16 y88 w480 h28", initialUrl)
    previewButton := strategyGui.AddButton("x16 y126 w145 h32", "Open Preview")
    saveButton := strategyGui.AddButton("x171 y126 w145 h32", "Save Link")
    closeButton := strategyGui.AddButton("x326 y126 w145 h32", "Close Window")
    strategyStatusText := strategyGui.AddText("x16 y168 w480 h38", "Tip: sharing permissions still apply. The preview opens in your default browser.")
    previewButton.OnEvent("Click", OpenStrategyPreview)
    saveButton.OnEvent("Click", SaveStrategyLink)
    closeButton.OnEvent("Click", (*) => strategyGui.Hide())
    strategyGui.OnEvent("Close", (*) => strategyGui.Hide())
    strategyGui.Show("w515 h220")
}

NormalizeGoogleDocsPreviewUrl(url) {
    url := Trim(url)
    if !RegExMatch(url, "^https?://docs\.google\.com/(document|spreadsheets|presentation)/d/([A-Za-z0-9_-]+)(?:/[^?#]*)?(?:[?#].*)?$", &match)
        return ""
    return "https://docs.google.com/" match[1] "/d/" match[2] "/preview"
}

OpenStrategyPreview(*) {
    global strategyUrlEdit, strategyStatusText
    previewUrl := NormalizeGoogleDocsPreviewUrl(strategyUrlEdit.Value)
    if (previewUrl = "") {
        strategyStatusText.Text := "Please paste a valid Google Docs, Sheets, or Slides URL."
        MsgBox("Paste a Google Docs, Sheets, or Slides link from docs.google.com.", "Invalid strategy link", "Icon!")
        return
    }
    try {
        Run(previewUrl)
        strategyStatusText.Text := "Preview opened in your default browser. This pinned helper stays on top."
        SaveStrategyLink()
    } catch as err {
        strategyStatusText.Text := "Could not open the preview. Check your default browser."
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
        strategyStatusText.Text := "Saved. Your preview-only link will be remembered next time."
    } catch as err {
        strategyStatusText.Text := "Couldn't save the link. Check folder permissions."
        MsgBox("Unable to save the strategy link." Chr(10) Chr(10) err.Message, "Save failed", "Icon!")
    }
}

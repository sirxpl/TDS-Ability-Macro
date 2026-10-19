; Separate Credits / About window for TDS Macro Studio.
; Add transparent circular PNG portraits at:
;   pictures\xpl.png
;   pictures\chatgpt.png

ShowCredits(*) {
    creditsGui := Gui("+Owner +MinSize540x390", "TDS Macro Studio - Credits")
    creditsGui.BackColor := "1E1E2E"
    creditsGui.SetFont("s18 cB4Befe Bold", "Segoe UI")
    creditsGui.AddText("x28 y22 w480 h32", "Credits")
    creditsGui.SetFont("s9 cB8C0D9", "Segoe UI")
    creditsGui.AddText("x28 y58 w480 h22", "The people and tools behind TDS Macro Studio")

    AddCreditCard(creditsGui, 28, 100, "xpl", "Project creator", "Creator of the project and feature ideas.", A_ScriptDir "\pictures\xpl.png")
    AddCreditCard(creditsGui, 28, 220, "ChatGPT", "AI development assistant", "Helped with code, design, debugging, and documentation.", A_ScriptDir "\pictures\chatgpt.png")

    creditsGui.SetFont("s10 cFFFFFF", "Segoe UI")
    repoButton := creditsGui.AddButton("x28 y344 w220 h34", "Open GitHub Repository")
    repoButton.OnEvent("Click", (*) => Run("https://github.com/sirxpl/TDS-Ability-Macro"))
    creditsGui.SetFont("s9 cB8C0D9", "Segoe UI")
    creditsGui.AddText("x270 y351 w240 h24", "TDS Macro Studio  •  GitHub")
    creditsGui.OnEvent("Close", (*) => creditsGui.Destroy())
    creditsGui.Show("w540 h400")
}

AddCreditCard(gui, x, y, personName, role, description, imagePath) {
    gui.AddText("x" x " y" y " w484 h104 Background292A3E", "")
    if FileExist(imagePath) {
        ; For the circular mask, use a PNG with a transparent circular crop.
        gui.AddPicture("x" (x + 14) " y" (y + 12) " w78 h78", imagePath)
    } else {
        gui.SetFont("s20 cB4Befe Bold", "Segoe UI")
        gui.AddText("x" (x + 14) " y" (y + 12) " w78 h78 Center +0x200 Background3B3D55", SubStr(personName, 1, 1))
    }
    gui.SetFont("s12 cFFFFFF Bold", "Segoe UI")
    gui.AddText("x" (x + 108) " y" (y + 12) " w350 h24", personName)
    gui.SetFont("s9 cB4Befe", "Segoe UI")
    gui.AddText("x" (x + 108) " y" (y + 38) " w350 h20", role)
    gui.SetFont("s9 cB8C0D9", "Segoe UI")
    gui.AddText("x" (x + 108) " y" (y + 60) " w350 h34", description)
}

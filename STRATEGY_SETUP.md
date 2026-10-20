# Pinned Strategy Setup

This guide explains how to configure the **Pinned Strategy** feature in TDS Macro Studio so a Google Docs, Sheets, or Slides strategy can appear inside an always-on-top window.

## 1. Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/) when running the `.ahk` source directly
- Microsoft Edge WebView2 Runtime
- The matching architecture of `WebView2Loader.dll` (x64 for 64-bit AutoHotkey, x86 for 32-bit AutoHotkey)

Most Windows 11 systems already have the WebView2 Runtime. If it is missing, install the Evergreen Runtime from the [official Microsoft WebView2 page](https://developer.microsoft.com/en-us/microsoft-edge/webview2/).

## 2. Install the WebView2 loader

The repository contains the AutoHotkey WebView2 wrapper and its helper files, but the native loader DLL must be placed in the repository yourself.

1. Open the [Microsoft.Web.WebView2 NuGet package](https://www.nuget.org/packages/Microsoft.Web.WebView2/1.0.2903.40).
2. Download the package and open the downloaded `.nupkg` as a ZIP archive (or rename a copy to `.zip`).
3. For **64-bit AutoHotkey**, copy `runtimes/win-x64/native/WebView2Loader.dll` to:
   `lib/64bit/WebView2Loader.dll`
4. For **32-bit AutoHotkey**, copy `runtimes/win-x86/native/WebView2Loader.dll` to:
   `lib/32bit/WebView2Loader.dll`

Create the destination folder if it does not exist. Keep the folder structure intact, including `lib/WebView2/WebView2.ahk`, `lib/Promise.ahk`, and `lib/ComVar.ahk`.

> **Important:** The DLL architecture must match the AutoHotkey process architecture. If the embedded browser does not start, double-check the loader path and install the WebView2 Runtime.

## 3. Prepare your Google strategy link

1. Open the Google Doc, Sheet, or Slide that contains your strategy.
2. Make sure your Google account has access to it.
3. Copy its normal Google Docs URL. Supported link types include:
   - `https://docs.google.com/document/d/DOCUMENT_ID/edit`
   - `https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit`
   - `https://docs.google.com/presentation/d/PRESENTATION_ID/edit`
4. Paste the link into the **Pinned Strategy** field in the main app.

The helper normalizes the URL to a `/preview` address. Google may block previews in an embedded browser for some documents or sharing configurations. If it does, try **Open Browser** or use a Google-provided embed/published preview link if appropriate.

### Privacy reminder

Do not publish a private strategy just to make embedding work unless you understand who will be able to access it. Google sharing and publishing settings determine who can view your document; the app does not bypass those permissions.

## 4. Open and save the pinned preview

1. Click **Pin Strategy** in the main app.
2. In the strategy window, click **Load Preview** to load the link in the embedded browser.
3. Click **Save Link** to remember the strategy link in `strategy.ini`.
4. Use **Open Browser** if the embedded preview is unavailable or Google asks you to sign in.
5. Resize or move the strategy window as needed. It is designed to stay on top of other windows.

The saved link is stored in `strategy.ini` beside the running script. Keep that file if you want to retain your saved strategy link.

## Troubleshooting

### The strategy window says the WebView2 loader is missing

Confirm the DLL exists at the correct path:

- 64-bit: `lib/64bit/WebView2Loader.dll`
- 32-bit: `lib/32bit/WebView2Loader.dll`

### The embedded area stays blank or Google refuses to display the document

- Verify the link opens in your regular browser and that you have permission to view it.
- Click **Open Browser** to check whether the issue is specific to embedded previews.
- Some Google pages require sign-in or do not permit embedding. Use a supported preview/embed link where available; do not make a private document public unless that is intentional.

### The browser fails to start

- Install or repair the [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/).
- Check that the loader DLL architecture matches AutoHotkey.
- Make sure the repository's `lib` and `src` folders remain beside `TDS-Ability-Macro.ahk`.

## Related files

- [Main README](README.md)
- [Strategy window source](src/StrategyWindow.ahk)
- [WebView2 wrapper](lib/WebView2/WebView2.ahk)

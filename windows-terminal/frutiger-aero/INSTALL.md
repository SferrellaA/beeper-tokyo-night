# Install

This theme runs on Windows, in Windows Terminal. WSL does not have its own theme. A WSL tab picks up the theme because Windows Terminal draws that tab.

You need Windows Terminal 1.16 or newer. The glass title bar needs Windows 11 build 22621 or newer. On Windows 10, the installer keeps the same colors and uses a solid tab row, because that release has no Mica. The colored window border only appears in Windows Terminal Preview.

Acrylic stays a flat color until Windows transparency is on: **Settings → Personalization → Colors → Transparency effects**.

## 1. Get the files onto the Windows PC

Clone the repository, or copy the `windows-terminal\frutiger-aero` folder onto the machine. The scripts read `fragments\`, `theme\`, and `assets\background.png` next to themselves, so run them from that folder, not from the repository root. Leave that image in the checkout. The installer points Windows Terminal at that file, not at a copy.

```powershell
cd path\to\windows-terminal\frutiger-aero
```

Open Windows Terminal once before you install. The first launch creates `settings.json`. The installer looks for that file in these places and updates each one it finds:

| Install | settings.json |
| --- | --- |
| Microsoft Store, stable | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| Microsoft Store, Preview | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json` |
| Scoop, winget, or a portable copy | `%LOCALAPPDATA%\Microsoft\Windows Terminal\settings.json` |

## 2. Quit Windows Terminal

Close every terminal window. If the icon is still in the system tray, right-click it and choose Close. The app keeps running after the last window closes, and a running instance will not reload a new fragment.

## 3. Run the installer

```bat
install.bat
```

That runs `install.ps1 -Apply`. From PowerShell, the same step is:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Apply
```

`-Apply` does both parts of the theme:

1. It copies the color schemes to `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\FrutigerAero\frutiger-aero.json`. Windows Terminal loads every JSON file in that folder and adds those schemes to the list in Settings.
2. It writes the tab-bar theme, the acrylic profile defaults, and the sky background into each `settings.json` it found. `backgroundImage` is the full path of `assets\background.png` in this folder. A relative path would be resolved next to `settings.json`, so the picture would not load.

The default follows Windows light and dark mode. Windows Terminal picks the pale sky theme and scheme when the OS is light, and the deep-water theme and scheme when the OS is dark. It cannot pick a different background image, so the tracked sky stays a 15% tint in both modes. That keeps dusk text readable. Pin one look with `-Variant`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Apply -Variant Light
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Apply -Variant Dusk
```

`Light` pins the pale sky scheme and uses the sky picture at full strength, including when Windows is in dark mode. `Dusk` pins the deep-water scheme and keeps the 15% tint.

`-Apply` rewrites `settings.json`. Comments in that file are removed, and the file is pretty-printed. Before the first write, the script copies the current file to `settings.json.frutiger-aero.bak` in the same folder. Later runs leave that first backup in place. If the new file cannot be parsed, the script puts the previous bytes back.

Without `-Apply`, the script only installs the color schemes. The tab bar and the acrylic glass stay as they are. Fragments cannot set a window theme.

## 4. Open Windows Terminal again

Start a new window. It should be using the theme immediately.

To confirm:

- The tab row is pale aqua in light mode, or deep water in dark mode.
- **Settings → Color schemes** lists **Frutiger Aero** and **Frutiger Aero Dusk**.
- A WSL tab, or any other profile, uses the sky or dusk background. The installer sets `profiles.defaults`, so every profile inherits it unless that profile has its own `colorScheme`.
- The text sits on frosted glass when Transparency effects are on. Lower `opacity` in `profiles.defaults` if you want more of the desktop to show through. `92` is almost opaque. `100` turns the frost off.

A profile that already sets `colorScheme`, `useAcrylic`, `opacity`, or `backgroundImage` keeps those values. Profile settings win over `profiles.defaults`. Clear the override on that profile's Appearance page, or delete those keys from that profile in `settings.json`, if one tab does not match the others.

## Install by hand

Use this when you do not want a script to rewrite `settings.json`.

Quit Windows Terminal the same way as in step 2.

Copy `fragments\frutiger-aero.json` to:

```text
%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\FrutigerAero\frutiger-aero.json
```

Create `FrutigerAero` if it is not there. The file has to be UTF-8. Windows PowerShell 5.1 `>` writes UTF-16, which Terminal will not load. Copy the file in Explorer, or save it from an editor as UTF-8.

Open the settings file. In Windows Terminal, open the dropdown in the title bar, choose **Settings**, and choose **Open JSON file** at the bottom of the settings sidebar. That is the current Settings screen. Ctrl+, opens that screen. It does not open the JSON file by itself.

Add the theme selector and the two theme objects. If `theme` or `themes` already exist, edit those keys. Do not add a second copy. The theme objects are the array in [`theme/window.json`](theme/window.json). Copy that array as it is.

```json
"theme": {
    "light": "Frutiger Aero",
    "dark": "Frutiger Aero Dusk"
},
"themes": [
    {
        "name": "Frutiger Aero"
    },
    {
        "name": "Frutiger Aero Dusk"
    }
]
```

The two objects above are only the names. Paste the full objects from `theme/window.json` in their place.

Then add these keys to `profiles` → `defaults`. If `defaults` already has other keys, add these beside them. Do not replace the whole `defaults` object, or you will drop font, padding, and other choices you already made.

```json
"colorScheme": {
    "light": "Frutiger Aero",
    "dark": "Frutiger Aero Dusk"
},
"useAcrylic": true,
"opacity": 92,
"backgroundImage": "C:\\path\\to\\windows-terminal\\frutiger-aero\\assets\\background.png",
"backgroundImageOpacity": 0.15,
"backgroundImageStretchMode": "uniformToFill",
"backgroundImageAlignment": "center"
```

`backgroundImage` has to be the full path of the tracked `assets\background.png`, with backslashes escaped. The other appearance keys are the whole of [`theme/appearance.json`](theme/appearance.json). That file stores the image as `assets/background.png` so the path stays portable in git. `install.bat` rewrites it to the full path when it updates `settings.json`.

Windows Terminal has one background image for both light and dark, so a fully opaque sky would hide the deep-water background and wash out the dusk text. `0.15` is faint enough that the dusk foreground stays readable when the OS switches. `install.bat -Variant Light` writes `1` instead, because that pin never shows the dusk scheme.

Save the file and start Windows Terminal again. A JSON error in the file makes Terminal open a warning and keep the last settings it could parse. The line number in that warning is the place to fix.

To pin a variant by hand, set both of these to the same string. Use `"Frutiger Aero"` or `"Frutiger Aero Dusk"`.

```json
"theme": "Frutiger Aero",
"colorScheme": "Frutiger Aero"
```

`colorScheme` in that pair belongs inside `profiles.defaults`. `theme` stays at the top level of the file.

Do not also paste the scheme objects into the `schemes` array if the fragment file is installed. The same scheme name would then be defined twice. To use the desktop wallpaper instead of the tracked sky, replace `backgroundImage` with `"desktopWallpaper"`.

## Schemes only

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Restart Windows Terminal. Under **Settings → Color schemes**, choose **Frutiger Aero** or **Frutiger Aero Dusk**, then on the profile's Appearance page set **Color scheme** to that name. This does not change the tab row or turn on acrylic.

## Remove

Quit Windows Terminal, then from the project folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1
```

The script deletes `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\FrutigerAero` and removes this theme from `settings.json` when the entries still match this project. It removes `useAcrylic` and `opacity` only when they are still `true` and `92`. It removes the background image keys only when `backgroundImage` is still the full path of this checkout's `assets\background.png`. It writes `settings.json.frutiger-aero.bak` first if that backup does not already exist.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1 -RevertSettings
```

`-RevertSettings` copies `settings.json.frutiger-aero.bak` back over `settings.json`. That backup is the file from the first install, so any edits made after that are lost.

To undo a hand install, delete the `FrutigerAero` fragment folder, delete the two theme objects named `Frutiger Aero` and `Frutiger Aero Dusk`, set `theme` back to `"system"`, and remove the `colorScheme`, `useAcrylic`, `opacity`, and `backgroundImage` keys you added under `profiles.defaults`.

## If it does not show up

| What you see | What to do |
| --- | --- |
| The installer says no `settings.json` was found | Open Windows Terminal once, quit it completely, and run the installer again. |
| The color schemes are missing from Settings | Quit Terminal from the tray, not only the window, and open it again. Confirm the fragment file is in the `Fragments\FrutigerAero` folder above. |
| The text color changed and the tab row did not | The schemes are installed and the window theme is not. Run `install.ps1 -Apply`, or add `theme` and `themes` by hand. |
| One profile is unchanged | That profile sets its own appearance. Clear **Color scheme**, **Acrylic**, and **Background image** on its Appearance page so it inherits `profiles.defaults`. |
| The background is a flat pale color | The sky image is a tint over the scheme color. Turn on **Transparency effects** if you also want the desktop to show through the acrylic. If the streaks are missing, run `install.bat` again from the folder that contains `assets\background.png`. |
| The sky picture is missing after the folder moved | `backgroundImage` is an absolute path. Run `install.bat` again from the new folder. |
| The title bar is a solid color on Windows 10 | Expected. Mica needs Windows 11 build 22621 or newer. |
| The new-tab plus and the window buttons are white on the pale tab row | The light theme's tab row must be `#ffffff00`, not `#00000000`. Re-apply the theme, or change that one color in the `Frutiger Aero` theme. |
| The window border is still the Windows default | `frame` only applies in Windows Terminal Preview, on Windows 11. |
| Terminal says the settings file is invalid | Restore `settings.json.frutiger-aero.bak` over `settings.json`, or fix the line it names. A missing comma before a key you pasted is the usual cause. |

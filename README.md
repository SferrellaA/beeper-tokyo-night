# Tokyo Night for Beeper Desktop

Custom CSS theme for Beeper Desktop. Night when the app is in dark mode, Day when it is in light mode.

Tested against the token names in Beeper Desktop **4.3.123** (the build in `/opt/beeper` on this machine). It overrides the palette those tokens read from (`--palette-gray-*`, `--palette-blueribbon-*`, `--palette-red-*`, and the alpha scales buttons actually paint with), plus the older `--color-*` variables still used by the sidebar and code blocks.

## What the September post actually is

The October 2, 2026 wrap-up (“A different look for desktop”) is [Chat Themes](https://help.beeper.com/en_US/desktop/chat-themes-on-beeper-desktop): a picker for a bubble color and a wallpaper, globally or per chat. That is not a theme-file format. A full app theme is still custom CSS, loaded from `custom.css` and injected as a `<style id="custom-css">` tag.

Chat Themes sit on top of this file. A per-chat wallpaper or bubble swatch still wins inside that conversation. For a flat Tokyo Night chat, set Appearance → Chat Appearance wallpaper to None and bubble color to Default.

## Install

Linux path: `~/.config/BeeperTexts/custom.css`

1. In Beeper: Settings → Appearance → Custom CSS → Open CSS file in editor.
2. Replace the file with `tokyo-night.css` from this folder. Or copy it:

   ```bash
   cp ~/Coding/beeper-tokyo-night/tokyo-night.css ~/.config/BeeperTexts/custom.css
   ```

3. Settings → Appearance → Custom CSS → **Reload CSS** (not Reset CSS).
   Command bar (`Ctrl+J`): “Reload custom CSS” does the same thing.
4. Set the appearance swatch to **Dark** for Night, **Light** for Day. “System” follows `prefers-color-scheme`, which Beeper also updates when you pick Light or Dark.

Reset CSS in that same settings section restores the stock theme.

## Palette

Night is [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) (`#1a1b26` / `#c0caf5` / `#7aa2f7`). Day is Tokyo Night Day (`#e1e2e7` / `#3760bf` / `#2e7de9`). Outgoing bubbles use the accent blue with the background color as text, so the light blue Night accent stays readable. A selected Appearance hue no longer washes the window in Beeper’s generated gradient.

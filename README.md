# Tokyo Night for Beeper Desktop

A custom CSS theme for [Beeper Desktop](https://www.beeper.com/). Dark mode uses [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme); light mode uses Tokyo Night Day.

Tested with Beeper Desktop 4.3.123. It overrides the palette those tokens read from (`--palette-gray-*`, `--palette-blueribbon-*`, `--palette-red-*`, and the alpha scales buttons paint with), plus the older `--color-*` variables still used by the sidebar and code blocks.

This is not a Beeper Chat Theme. Chat Themes are a bubble color and a wallpaper, set globally or per chat. A full app theme is still custom CSS, loaded from `custom.css`. A per-chat wallpaper or bubble color still wins inside that conversation. For a flat Tokyo Night chat, set Appearance → Chat Appearance wallpaper to None and bubble color to Default.

## Install

1. Open Beeper Desktop → Settings → Appearance → Custom CSS → **Open CSS file in editor**.
2. Replace the file contents with [`tokyo-night.css`](./tokyo-night.css) and save.
3. Settings → Appearance → Custom CSS → **Reload CSS** (not Reset CSS). The command bar (`Ctrl+J` / `Cmd+J`) action “Reload custom CSS” does the same thing.
4. Set the appearance swatch to **Dark** for Night or **Light** for Day. **System** follows `prefers-color-scheme`.

On Linux the file is `~/.config/BeeperTexts/custom.css`. Reset CSS in that same settings section restores the stock theme.

Custom CSS can cause visual bugs. If it does, Reset CSS.

## Palette

| | Background | Foreground | Accent |
| --- | --- | --- | --- |
| Night | `#1a1b26` | `#c0caf5` | `#7aa2f7` |
| Day | `#e1e2e7` | `#3760bf` | `#2e7de9` |

Outgoing bubbles use the accent blue with the background color as text, so the light Night accent stays readable. A selected Appearance hue no longer washes the window in Beeper’s generated gradient.

Colors are from [enkia/tokyo-night-vscode-theme](https://github.com/enkia/tokyo-night-vscode-theme). This file is only the Beeper mapping.

## License

[MIT](./LICENSE)

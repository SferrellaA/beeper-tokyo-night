# Themes for Beeper Desktop

Custom CSS themes for [Beeper Desktop](https://www.beeper.com/). Pick one file and load it as `custom.css`.

- [Tokyo Night](./tokyo-night.css) — dark mode is [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme); light mode is Tokyo Night Day.
- [Frutiger Aero](./frutiger-aero.css) — day is Vista-style sky glass; night is the same look as aurora over deep water.

Tested against the Beeper Desktop 4.3 token stack. Each file overrides the palette those tokens read from (`--palette-gray-*`, `--palette-blueribbon-*`, `--palette-red-*`, and the alpha scales buttons paint with), plus the older `--color-*` variables still used by the sidebar and code blocks.

These are not Beeper Chat Themes. Chat Themes are a bubble color and a wallpaper, set globally or per chat. A full app theme is still custom CSS, loaded from `custom.css`. A per-chat wallpaper or bubble color still wins inside that conversation. For the theme’s own chat surface, set Appearance → Chat Appearance wallpaper to None and bubble color to Default.

## Install

1. Open Beeper Desktop → Settings → Appearance → Custom CSS → **Open CSS file in editor**.
2. Replace the file contents with [`tokyo-night.css`](./tokyo-night.css) or [`frutiger-aero.css`](./frutiger-aero.css) and save.
3. Settings → Appearance → Custom CSS → **Reload CSS** (not Reset CSS). The command bar (`Ctrl+J` / `Cmd+J`) action “Reload custom CSS” does the same thing.
4. Set the appearance swatch to **Dark** or **Light**. **System** follows `prefers-color-scheme`.

On Linux the file is `~/.config/BeeperTexts/custom.css`. Reset CSS in that same settings section restores the stock theme.

Custom CSS can cause visual bugs. If it does, Reset CSS.

## Tokyo Night

| | Background | Foreground | Accent |
| --- | --- | --- | --- |
| Night | `#1a1b26` | `#c0caf5` | `#7aa2f7` |
| Day | `#e1e2e7` | `#3760bf` | `#2e7de9` |

Outgoing bubbles use the accent blue with the background color as text, so the light Night accent stays readable. A selected Appearance hue no longer washes the window in Beeper’s generated gradient.

Colors are from [enkia/tokyo-night-vscode-theme](https://github.com/enkia/tokyo-night-vscode-theme). `tokyo-night.css` is only the Beeper mapping.

## Frutiger Aero

| | Background | Foreground | Accent |
| --- | --- | --- | --- |
| Day | `#e7f6ff` | `#08365a` | `#008ed6` |
| Night | `#071828` | `#e7f7ff` | `#5ad4ff` |

Day paints a sky gradient (white glare, aqua, a grass-green horizon) and keeps panels a glassy white-blue. Night uses the same glass language on a deep ocean field with a faint cyan and green aurora. Outgoing bubbles are glossy aqua with near-white text. Scrollbar thumbs are pill-shaped highlights. A selected Appearance hue does not replace the sky.

Bubble chrome is still token-colored. Beeper does not expose a stable selector for a gloss gradient on each bubble, so the shine is in the window, the scrollbar, and the palette rather than painted onto every message.

## License

[MIT](../LICENSE)

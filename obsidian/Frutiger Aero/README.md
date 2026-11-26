# Frutiger Aero for Obsidian

Vista glass over the aurora wallpaper. Day uses the pale aqua panels from the [Frutiger Aero Archive](https://frutigeraeroarchive.org/) theme. Night is the same chrome on deep water, so the wallpaper stays readable.

The picture is [`assets/windows_vista_59.jpg`](assets/windows_vista_59.jpg), from [windows_vista_59.jpg](https://frutigeraeroarchive.org/images/wallpapers/windows_vista/windows_vista_59.jpg). Icons are PNG extracts of the Vista and Explorer icons on [the archive icon page](https://frutigeraeroarchive.org/icons). Obsidian draws them as CSS backgrounds. They do not need to be SVG. Lucide icons that this theme does not replace stay as they are.

## Install

This folder is already named `Frutiger Aero`, which is the `name` in [`manifest.json`](manifest.json). Obsidian hides a theme whose folder name does not match that field.

1. Copy this directory into `<vault>/.obsidian/themes/`. Leave the folder name as `Frutiger Aero`.
2. Restart Obsidian if it was already open.
3. Settings → Appearance → Themes → **Frutiger Aero**.
4. Pick **Light** or **Dark**. **System** follows the OS.

A symlink is fine if the link name is `Frutiger Aero`.

## What you see

| Piece | Light | Dark |
| --- | --- | --- |
| Wallpaper | Aurora, full strength | Same picture, darker glass on top |
| Panels | `#f2faff` glass, archive aqua sidebar | `#071828` glass |
| Accent | `#128ddf` | `#5ad4ff` |
| Title bar | Archive split-horizon blue | Deeper split of the same blue |
| Text | `#102030` | `#e7f7ff` |

Title-bar and button gradients match `frutiger_aero.css` on the archive: `#9ad1fc` through `#128ddf` to `#1488d6`, with `#63e8ff` on hover. Links are `#1c95e6`. Selection is `#38acfa`.

## Icons

PNG, 128px (the book is 48px in the source icon). File-tree and pane-header icons do not depend on UI language. Ribbon icons use the English labels from Obsidian (`Open file explorer`, `Search in all files`, `Show bookmarks`, `Open graph view`, `Open today's daily note`, `Settings`, `Help`). A translated UI keeps the file-tree icons and leaves the ribbon on Lucide.

| Icon | Used for |
| --- | --- |
| `folder.png` | Folders. Plain Vista folder, not the drive or Explorer window |
| `files.png` | File explorer ribbon and pane |
| `book.png` | Markdown notes, bookmarks, quote callouts |
| `pdf.png` | PDF files. Adobe's document icon; Vista itself had none |
| `note.png` | Other files, note / todo callouts |
| `search.png` | Search |
| `graph.png` | Graph view |
| `calendar.png` | Daily note ribbon button |
| `settings.png` | Settings |
| `help.png` | Help, tip callouts |
| `info.png` | Info and question callouts |
| `warning.png` | Warning, danger, bug callouts |
| `shield.png` | Success callouts |
| `image.png` | Image files. Vista's picture icon, a landscape in a frame |
| `video.png` | Video files |
| `console.png` | Code files, example callouts |
| `share.png` | Canvas, backlinks |
| `sidebar.png` | Outline |
| `computer.png`, `trash.png`, `marketplace.png`, `accessibility.png` | In the folder if you want them in a snippet. Not wired to a control. |

The picture and icons are embedded in `theme.css`. Obsidian does not load a relative `assets/` path from a theme, so the files in `assets/` are the sources, not what the app reads.

## License

Theme CSS and this note are [MIT](../../LICENSE). The wallpaper and icons are not. They come from the Frutiger Aero Archive and from Windows Vista / Windows 7, and they stay under their own terms.

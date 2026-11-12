#!/usr/bin/env python3
"""Check the theme files against the Windows Terminal settings shape."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SCHEME_KEYS = (
    "black",
    "red",
    "green",
    "yellow",
    "blue",
    "purple",
    "cyan",
    "white",
    "brightBlack",
    "brightRed",
    "brightGreen",
    "brightYellow",
    "brightBlue",
    "brightPurple",
    "brightCyan",
    "brightWhite",
)
RESERVED_THEME_NAMES = {"dark", "light", "system"}
THEME_COLOR_WORDS = {"accent", "terminalBackground"}
CLOSE_BUTTONS = {"always", "hover", "never", "activeOnly"}
APPLICATION_THEMES = {"system", "dark", "light"}

errors = []


def fail(message):
    errors.append(message)


def load(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"{path.relative_to(ROOT)} is not valid JSON: {exc}")
        return None


def luminance(hex_color):
    channels = []
    for index in (0, 2, 4):
        value = int(hex_color[1 + index : 3 + index], 16) / 255
        if value <= 0.04045:
            channels.append(value / 12.92)
        else:
            channels.append(((value + 0.055) / 1.055) ** 2.4)
    red, green, blue = channels
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def contrast(left, right):
    lighter = max(luminance(left), luminance(right))
    darker = min(luminance(left), luminance(right))
    return (lighter + 0.05) / (darker + 0.05)


def require_hex(path, label, value):
    if not isinstance(value, str) or len(value) != 7 or not value.startswith("#"):
        fail(f"{path}: {label} must be a #rrggbb color, got {value!r}")
        return False
    try:
        int(value[1:], 16)
    except ValueError:
        fail(f"{path}: {label} is not hexadecimal: {value}")
        return False
    return True


def require_contrast(path, label, color, background, minimum):
    ratio = contrast(color, background)
    if ratio < minimum:
        fail(
            f"{path}: {label} {color} on {background} is {ratio:.2f}:1, "
            f"below {minimum:.1f}:1"
        )


def check_scheme(path, data, bright_minimum, black_minimum):
    if not isinstance(data, dict):
        fail(f"{path}: scheme must be an object")
        return
    name = data.get("name")
    if not isinstance(name, str) or not name.strip():
        fail(f"{path}: scheme needs a name")
    background = data.get("background")
    if not require_hex(path, "background", background):
        return
    for key in ("foreground", "cursorColor", "selectionBackground", *SCHEME_KEYS):
        if key not in data:
            fail(f"{path}: missing {key}")
            continue
        require_hex(path, key, data[key])
    extra = set(data) - {"name", "background", "foreground", "cursorColor", "selectionBackground", *SCHEME_KEYS}
    if extra:
        fail(f"{path}: unexpected keys {sorted(extra)}")
    if not all(isinstance(data.get(key), str) for key in ("foreground", "cursorColor", "selectionBackground", *SCHEME_KEYS)):
        return

    require_contrast(path, "foreground", data["foreground"], background, 7.0)
    require_contrast(path, "cursorColor", data["cursorColor"], background, 4.5)
    require_contrast(path, "foreground on selection", data["foreground"], data["selectionBackground"], 4.5)
    for key in SCHEME_KEYS:
        if key == "brightWhite":
            continue
        minimum = black_minimum if key == "black" else bright_minimum if key.startswith("bright") else 4.5
        require_contrast(path, key, data[key], background, minimum)


def check_theme_color(path, label, value):
    if value in THEME_COLOR_WORDS:
        return
    if not isinstance(value, str) or not value.startswith("#"):
        fail(f"{path}: {label} must be a hex color or accent/terminalBackground")
        return
    digits = value[1:]
    if len(digits) not in (3, 6, 8) or any(char not in "0123456789abcdefABCDEF" for char in digits):
        fail(f"{path}: {label} has a bad color {value}")


schemes = {}
for scheme_path in sorted((ROOT / "schemes").glob("*.json")):
    scheme = load(scheme_path)
    if scheme is None:
        continue
    relative = scheme_path.relative_to(ROOT).as_posix()
    if scheme.get("name") == "Frutiger Aero Dusk":
        check_scheme(relative, scheme, bright_minimum=4.5, black_minimum=2.2)
    else:
        check_scheme(relative, scheme, bright_minimum=3.5, black_minimum=4.5)
    schemes[scheme.get("name")] = scheme

fragment = load(ROOT / "fragments" / "frutiger-aero.json")
if isinstance(fragment, dict):
    fragment_schemes = fragment.get("schemes")
    if not isinstance(fragment_schemes, list) or not fragment_schemes:
        fail("fragments/frutiger-aero.json needs a non-empty schemes array")
    else:
        by_name = {item.get("name"): item for item in fragment_schemes if isinstance(item, dict)}
        if set(by_name) != set(schemes):
            fail("fragment schemes do not match schemes/*.json")
        for name, scheme in schemes.items():
            if by_name.get(name) != scheme:
                fail(f"fragment copy of {name!r} differs from schemes/")
    if set(fragment) - {"schemes"}:
        fail("fragments can only contain schemes; themes are not fragment settings")

window = load(ROOT / "theme" / "window.json")
appearance = load(ROOT / "theme" / "appearance.json")

if isinstance(window, dict):
    theme_list = window.get("themes")
    if not isinstance(theme_list, list) or len(theme_list) != 2:
        fail("theme/window.json needs the light and dusk themes")
        theme_list = []
    names = []
    for theme in theme_list:
        if not isinstance(theme, dict):
            fail("a theme entry is not an object")
            continue
        name = theme.get("name")
        names.append(name)
        if name in RESERVED_THEME_NAMES or not isinstance(name, str):
            fail(f"theme name {name!r} is missing or reserved")
        window_settings = theme.get("window") or {}
        if window_settings.get("applicationTheme") not in APPLICATION_THEMES:
            fail(f"{name}: applicationTheme must be light, dark, or system")
        if not isinstance(window_settings.get("useMica"), bool):
            fail(f"{name}: useMica must be a boolean")
        for key in ("frame", "unfocusedFrame"):
            check_theme_color(f"theme {name}", f"window.{key}", window_settings.get(key))
        tab = theme.get("tab") or {}
        check_theme_color(f"theme {name}", "tab.background", tab.get("background"))
        check_theme_color(f"theme {name}", "tab.unfocusedBackground", tab.get("unfocusedBackground"))
        if tab.get("showCloseButton") not in CLOSE_BUTTONS:
            fail(f"{name}: showCloseButton is invalid")
        tab_row = theme.get("tabRow") or {}
        check_theme_color(f"theme {name}", "tabRow.background", tab_row.get("background"))
        check_theme_color(f"theme {name}", "tabRow.unfocusedBackground", tab_row.get("unfocusedBackground"))
    selector = window.get("theme")
    if not isinstance(selector, dict):
        fail("theme/window.json theme selector must be an object with light and dark")
    else:
        for mode in ("light", "dark"):
            if selector.get(mode) not in names:
                fail(f"theme.{mode} does not name a theme in the file")

if isinstance(appearance, dict):
    scheme_choice = appearance.get("colorScheme")
    if not isinstance(scheme_choice, dict):
        fail("appearance colorScheme must switch with light and dark")
    else:
        for mode in ("light", "dark"):
            if scheme_choice.get(mode) not in schemes:
                fail(f"appearance colorScheme.{mode} does not match a scheme")
    if appearance.get("useAcrylic") is not True:
        fail("appearance should turn acrylic on")
    opacity = appearance.get("opacity")
    if not isinstance(opacity, int) or not 0 <= opacity <= 100:
        fail("appearance opacity must be an integer from 0 to 100")
    if appearance.get("backgroundImage") != "assets/background.png":
        fail("appearance backgroundImage must be the tracked assets/background.png")
    image = ROOT / "assets" / "background.png"
    if not image.is_file() or image.read_bytes()[:8] != b"\x89PNG\r\n\x1a\n":
        fail("assets/background.png is missing or is not a PNG")
    image_opacity = appearance.get("backgroundImageOpacity")
    if isinstance(image_opacity, bool) or not isinstance(image_opacity, (int, float)) or not 0 < image_opacity <= 1:
        fail("appearance backgroundImageOpacity must be a number from 0 to 1")
    if appearance.get("backgroundImageStretchMode") != "uniformToFill":
        fail("appearance backgroundImageStretchMode must be uniformToFill")
    if appearance.get("backgroundImageAlignment") != "center":
        fail("appearance backgroundImageAlignment must be center")
    expected = {
        "colorScheme",
        "useAcrylic",
        "opacity",
        "backgroundImage",
        "backgroundImageOpacity",
        "backgroundImageStretchMode",
        "backgroundImageAlignment",
    }
    if set(appearance) != expected:
        fail(f"appearance has unexpected keys: {sorted(set(appearance) - expected)}")

if errors:
    for message in errors:
        print(message, file=sys.stderr)
    sys.exit(1)

print(f"Validated {len(schemes)} schemes and {len(window.get('themes', []))} window themes.")

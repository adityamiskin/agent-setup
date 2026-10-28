# Desktop Widgets

macOS-style widgets on the wallpaper. Each `*.owl` widget from
[Omalauncher](https://github.com/SimonSchubert/omalauncher) (OWL) is drawn on a
transparent, click-through layer surface on Hyprland's **bottom layer**: visible
over the wallpaper, behind every window, on every workspace.

The plugin runs inside `omarchy-shell`, so widget colors follow the active
Omarchy theme automatically.

- Widgets: `~/.config/omarchy-widgets/*.owl` (the same files Omalauncher's bar
  panel uses, including ones installed from the widget store)
- Arrangement: `~/.config/omarchy-widgets/desktop.json` (optional — without it,
  widgets are packed top-right)
- Toggle: `SUPER + ALT + W`, or `omarchy-shell aditya.desktop-widgets toggle`

## Commands

```bash
omarchy-shell aditya.desktop-widgets toggle      # show/hide the layer
omarchy-shell aditya.desktop-widgets show
omarchy-shell aditya.desktop-widgets hide
omarchy-shell aditya.desktop-widgets reload      # rescan .owl files + desktop.json
omarchy-shell aditya.desktop-widgets saveLayout  # write the current arrangement to desktop.json
```

## desktop.json

```json
{
  "pitch": 96,
  "gap": 12,
  "margin": 32,
  "topInset": 40,
  "widgets": [
    { "file": "market-simonschubert-fetch.owl", "col": -6, "row": 0 },
    { "file": "market-simonschubert-today.owl", "col": -3, "row": 0,
      "cols": 3, "rows": 3 }
  ]
}
```

| Key | Meaning |
| --- | --- |
| `pitch` | One grid cell in px. Widgets are written against a 69 px cell. |
| `gap` | Gap between tiles in px. |
| `margin` | Left/right margin in px. |
| `topInset` | Distance from the top of the screen in px (keep it below the bar). |
| `widgets[].file` | File name inside `~/.config/omarchy-widgets`. |
| `widgets[].col` | Column. Negative numbers measure from the right margin: a 3-wide tile at `-3` is flush with it, and `-6` sits three columns to its left. |
| `widgets[].row` | Row. |
| `widgets[].cols` / `rows` | Optional override; defaults to the widget's declared `size:`. |
| `widgets[].hidden` | `true` keeps the widget out of the layout. |

A widget that is not listed is not shown. Changes to the file are picked up
immediately.

## How it works

- One small `PanelWindow` per tile, on `WlrLayer.Bottom`, `ExclusionMode.Ignore`,
  `WlrKeyboardFocus.None`, transparent, on every workspace. There is no
  fullscreen surface, so clicks between and around widgets go to the desktop.
- Widgets use the vendored OWL runtime in `./owl`, with an `OwlHost` that
  launches terminals, apps, URLs and media through Omarchy's commands.
- Widget state (`state ... persist`) lives in
  `~/.local/state/desktop-widgets/<widget>.json`.

## Things to know

- **Animated widgets are expensive when always on screen.** The koi-pond
  widget re-renders its OWL tree every frame and costs roughly a full CPU core
  (in the bar panel too, not just here). It is left out of the default layout;
  add it only if you want it. Clock/weather/system widgets tick at most once a
  second and idle at ~0%.
- Tapping a widget that calls `screen()` (a full-screen detail view) currently
  does nothing; per-widget buttons and taps that call `terminal()`, `app()`,
  `url()` and media actions work.
- Right-click/long-press to rearrange is not implemented yet; edit
  `desktop.json` or run `saveLayout` and move entries around.

## Attribution

`owl/` is the OWL widget runtime from
[SimonSchubert/omalauncher-omarchy-plugin](https://github.com/SimonSchubert/omalauncher-omarchy-plugin),
MIT licensed. The license text is in `LICENSE.omalauncher`. The rest of this
plugin is MIT.

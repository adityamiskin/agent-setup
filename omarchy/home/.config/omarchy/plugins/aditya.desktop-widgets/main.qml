pragma ComponentBehavior: Bound

// Desktop Widgets: Omalauncher's OWL widgets on the wallpaper.
//
// A layer-shell surface per widget on the bottom layer, behind every window
// and over the wallpaper, on every workspace. Nothing is mapped between the
// tiles, so clicks on the desktop pass through untouched. Widgets are the
// *.owl files in ~/.config/omarchy-widgets, arranged by
// ~/.config/omarchy-widgets/desktop.json (or packed top-right when that file
// does not exist yet).
//
// The OWL runtime in ./owl is vendored from Omalauncher (MIT, see
// LICENSE.omalauncher), so widgets behave exactly as they do in the bar panel.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import "owl" as Owl
import "owl/Owl.js" as OwlJs

Item {
  id: root

  // Injected by omarchy-shell for panel/overlay plugins.
  property var shell: null
  property var manifest: null
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")

  readonly property string home: Quickshell.env("HOME") || ""
  readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || (root.home + "/.local/state")
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (root.home + "/.config")
  readonly property string widgetDir: root.configHome + "/omarchy-widgets"
  readonly property string layoutPath: root.widgetDir + "/desktop.json"

  // ------------------------------------------------------------ state

  property bool shown: true
  // ARGB palette for OWL, from the live Omarchy theme.
  property var palette: OwlJs.themeFromToml("")
  // [{ file, w, h }] found on disk.
  property var found: []
  // Parsed desktop.json, or null.
  property var layout: null
  // Resolved tiles: [{ file, col, row, cols, rows }].
  property var tiles: []

  readonly property real pitch: root.layout && root.layout.pitch ? root.layout.pitch : 96
  readonly property real gap: root.layout && root.layout.gap !== undefined ? root.layout.gap : 12
  readonly property real margin: root.layout && root.layout.margin !== undefined ? root.layout.margin : 32
  readonly property real topInset: root.layout && root.layout.topInset !== undefined ? root.layout.topInset : 40
  // One OWL dp, kept at the launcher's proportion so widgets look the same.
  readonly property real dp: root.pitch / 69
  readonly property real screenWidth: Quickshell.screens.length > 0 ? Quickshell.screens[0].width : 0
  readonly property real screenHeight: Quickshell.screens.length > 0 ? Quickshell.screens[0].height : 0
  readonly property int columns: Math.max(1, Math.floor((root.screenWidth - 2 * root.margin + root.gap) / root.pitch))

  onColumnsChanged: root.rebuild()
  onFoundChanged: root.rebuild()

  // ------------------------------------------------------------ theme

  function ink(name) {
    var v = root.palette[name]
    return v === undefined || v === null ? "#888888" : OwlJs.hex8(v)
  }

  function inkA(name, alpha) {
    var v = root.palette[name]
    if (v === undefined || v === null) return Qt.rgba(0.5, 0.5, 0.5, alpha)
    var n = v >>> 0
    return Qt.rgba(((n >>> 16) & 0xff) / 255, ((n >>> 8) & 0xff) / 255, (n & 0xff) / 255,
                   (((n >>> 24) & 0xff) / 255) * alpha)
  }

  FileView {
    path: root.stateHome + "/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.palette = OwlJs.themeFromToml(text())
  }

  // ------------------------------------------------------------ widgets on disk

  // Every *.owl in the folder (and a couple of levels down, so a store
  // checkout works as-is), with the grid size it declares.
  Process {
    id: scan
    command: ["bash", "-c",
      "mkdir -p \"$1\" && cd \"$1\" && find -L . -maxdepth 3 -name '*.owl' -not -path '*/.*' -print0 | sort -z | " +
      "while IFS= read -r -d '' f; do s=$(grep -m1 -oE 'size:[[:space:]]*[0-9]+x[0-9]+' \"$f\" | grep -oE '[0-9]+x[0-9]+'); " +
      "printf '%s\\t%s\\n' \"${f#./}\" \"${s:-3x3}\"; done",
      "scan", root.widgetDir]
    stdout: StdioCollector {
      onStreamFinished: {
        var out = []
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i]
          if (!line) continue
          var parts = line.split("\t")
          if (!parts[0]) continue
          var dims = (parts[1] || "3x3").split("x")
          out.push({ file: parts[0], w: parseInt(dims[0]) || 3, h: parseInt(dims[1]) || 3 })
        }
        root.found = out
      }
    }
  }

  FileView {
    id: layoutFile
    path: root.layoutPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var parsed = null
      try { parsed = JSON.parse(text()) } catch (e) { parsed = null }
      root.layout = parsed
      root.rebuild()
    }
    onLoadFailed: { root.layout = null; root.rebuild() }
  }

  Component.onCompleted: scan.running = true

  // ------------------------------------------------------------ arrangement

  function findSize(file) {
    for (var i = 0; i < root.found.length; i++)
      if (root.found[i].file === file) return root.found[i]
    return { file: file, w: 3, h: 3 }
  }

  // Pack the files top-right, like macOS puts new widgets there.
  function autoCells(files) {
    var per = []
    var row = []
    var used = 0
    for (var i = 0; i < files.length; i++) {
      var f = files[i]
      var w = Math.max(1, Math.min(f.w || 3, root.columns))
      var h = f.h || 3
      if (row.length && used + w > root.columns) {
        per.push({ items: row, used: used })
        row = []
        used = 0
      }
      row.push({ file: f.file, col: used, w: w, h: h })
      used += w
    }
    if (row.length) per.push({ items: row, used: used })

    var out = []
    var y = 0
    for (var r = 0; r < per.length; r++) {
      var group = per[r]
      var tallest = 0
      for (var j = 0; j < group.items.length; j++) {
        var it = group.items[j]
        // Negative columns right-align the row, which is where macOS keeps
        // widgets and how -N is written in desktop.json.
        out.push({ file: it.file, col: -(group.used - it.col), row: y, cols: it.w, rows: it.h })
        tallest = Math.max(tallest, it.h)
      }
      y += tallest
    }
    return out
  }

  function rebuild() {
    var out = []
    if (root.layout && Array.isArray(root.layout.widgets)) {
      for (var i = 0; i < root.layout.widgets.length; i++) {
        var e = root.layout.widgets[i]
        if (!e || !e.file || e.hidden) continue
        var size = root.findSize(e.file)
        out.push({
          file: e.file,
          col: typeof e.col === "number" ? e.col : 0,
          row: typeof e.row === "number" ? e.row : 0,
          cols: e.cols || size.w,
          rows: e.rows || size.h
        })
      }
    } else {
      out = root.autoCells(root.found)
    }
    root.tiles = out
  }

  // Writes the arrangement currently on screen to desktop.json, which the file
  // watcher then picks up (same layout, now editable).
  function saveLayout() {
    var widgets = []
    for (var i = 0; i < root.tiles.length; i++) {
      var t = root.tiles[i]
      widgets.push({ file: t.file, col: t.col, row: t.row, cols: t.cols, rows: t.rows })
    }
    var data = { pitch: root.pitch, gap: root.gap, margin: root.margin, topInset: root.topInset, widgets: widgets }
    var json = JSON.stringify(data, null, 2) + "\n"
    Quickshell.execDetached(["bash", "-c", "mkdir -p \"$2\" && printf '%s' \"$1\" > \"$3\"",
                             "save", json, root.widgetDir, root.layoutPath])
    return json
  }

  // ------------------------------------------------------------ the host

  Owl.OwlHost {
    id: host
    dp: root.dp
    sansFamily: Style.font.resolvedFamily || "monospace"
    monoFamily: Style.font.resolvedFamily || "monospace"
    // Omarchy's fonts are Nerd Fonts, which carry weatherIcon()'s glyphs.
    iconFamily: Style.font.resolvedFamily || "monospace"
    stateDir: root.stateHome + "/desktop-widgets"

    function act(widget, name, args) {
      var a = args || []
      function s(i) { return a[i] === undefined || a[i] === null ? "" : String(a[i]) }
      switch (name) {
      case "terminal":
        return Quickshell.execDetached(["bash", "-c",
          "if command -v omarchy-launch-tui >/dev/null; then exec omarchy-launch-tui --app-id=org.omarchy.desktop-widgets bash -c \"$1; exec bash\"; " +
          "else exec xdg-terminal-exec bash -c \"$1; exec bash\"; fi", "terminal", s(0)])
      case "launcher":
        var route = { themes: "theme", drawer: "apps" }[s(0)]
        if (route) return Quickshell.execDetached(["bash", "-c", "command -v omarchy-menu >/dev/null && exec omarchy-menu summon \"$1\"", "launcher", route])
        return widget.report("launcher(\"" + s(0) + "\") opens a screen the desktop has no counterpart for")
      }
      host.defaultAct(widget, name, a)
    }
  }

  // ------------------------------------------------------------ windows

  // One small layer-shell surface per tile. Nothing else belongs to the plugin,
  // so every click that is not on a tile reaches the desktop, and an animated
  // widget only repaints its own surface.
  Variants {
    model: root.shown ? root.tiles : []

    delegate: Component {
      PanelWindow {
        id: tileWindow
        required property var modelData
        readonly property var entry: modelData
        readonly property real resolvedX: entry.col >= 0
          ? root.margin + entry.col * root.pitch
          : root.screenWidth - root.margin + root.gap - Math.abs(entry.col) * root.pitch

        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; left: true }
        margins {
          top: Math.round(root.topInset + entry.row * root.pitch)
          left: Math.round(tileWindow.resolvedX)
        }
        implicitWidth: Math.round(Math.max(root.pitch - root.gap, entry.cols * root.pitch - root.gap))
        implicitHeight: Math.round(Math.max(root.pitch - root.gap, entry.rows * root.pitch - root.gap))
        color: "transparent"
        surfaceFormat.opaque: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "aditya-desktop-widgets"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Rectangle {
          anchors.fill: parent
          radius: 8 * root.dp
          color: widget.tree && widget.tree.background
            ? OwlJs.hex8(widget.tree.background) : root.ink("background")
          border.width: Math.max(1, Math.round(1 * root.dp))
          border.color: root.inkA("foreground", 0.12)
        }

        Owl.OwlWidget {
          id: widget
          anchors.fill: parent
          anchors.margins: (widget.program ? widget.program.padding : 12) * root.dp
          path: root.widgetDir + "/" + tileWindow.entry.file
          host: host
          palette: root.palette
          active: root.shown
          cols: tileWindow.entry.cols
          rows: tileWindow.entry.rows
          cell: root.pitch
          dp: root.dp
          screenWidth: root.screenWidth
          screenHeight: root.screenHeight
        }

        Owl.OwlNode {
          anchors.fill: widget
          visible: !widget.error && !!widget.tree
          widget: widget
          node: widget.tree && widget.tree.children.length === 1
            ? widget.tree.children[0]
            : (widget.tree ? { kind: "Column", p: { gap: 0 }, h: {}, a: {}, c: widget.tree.children } : null)
        }

        TapHandler {
          enabled: !!(widget.tree && widget.tree.onTap)
          onTapped: function (p) {
            widget.tree.onTap((p.position.x - widget.x) / widget.dp,
                              (p.position.y - widget.y) / widget.dp)
          }
        }

        Text {
          anchors.fill: widget
          visible: !!widget.error
          text: widget.error
          color: root.ink("red")
          font.family: Style.font.resolvedFamily || "monospace"
          font.pixelSize: Math.max(9, 10 * root.dp)
          wrapMode: Text.Wrap
          elide: Text.ElideRight
        }
      }
    }
  }

  // ------------------------------------------------------------ IPC

  IpcHandler {
    target: "aditya.desktop-widgets"

    function toggle(): string {
      root.shown = !root.shown
      if (root.shown) scan.running = true
      return root.shown ? "shown" : "hidden"
    }
    function show(): string {
      root.shown = true
      scan.running = true
      return "shown"
    }
    function hide(): string {
      root.shown = false
      return "hidden"
    }
    function reload(): string {
      scan.running = true
      layoutFile.reload()
      return "reloading"
    }
    function saveLayout(): string {
      return root.saveLayout()
    }
    // Diagnostic: what the plugin thinks it is showing.
    function state(): string {
      return JSON.stringify({ shown: root.shown, tiles: root.tiles })
    }
  }
}

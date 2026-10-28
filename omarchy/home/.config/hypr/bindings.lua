-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

for _, keys in ipairs({
  "SUPER + SHIFT + A", "SUPER + SHIFT + ALT + A",
  "SUPER + SHIFT + C",
  "SUPER + SHIFT + E", "SUPER + SHIFT + ALT + E",
  "SUPER + SHIFT + Y",
  "SUPER + SHIFT + ALT + G", "SUPER + SHIFT + CTRL + G",
  "SUPER + SHIFT + P",
  "SUPER + SHIFT + X", "SUPER + SHIFT + ALT + X",
}) do
  hl.unbind(keys)
end

-- strata-installer: file-manager start
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = "/usr/bin/strata" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)",
  "uwsm-app -- /usr/bin/strata \"$(omarchy-cmd-terminal-cwd)\"")
-- strata-installer: file-manager end

-- Launcher: Keystroke (replaces the Omarchy menu / oma-cast on SUPER + SPACE).
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Launcher (Keystroke)", "omarchy-menu toggle root")

-- Desktop widgets: show/hide the macOS-style widget layer (aditya.desktop-widgets).
o.bind("SUPER + ALT + W", "Desktop widgets", "omarchy-shell aditya.desktop-widgets toggle")

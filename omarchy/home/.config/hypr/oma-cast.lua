-- Written by `oma-cast setup hyprland`. Safe to edit; rerunning setup overwrites it.
-- Super+Space reaches the plugin's global shortcut directly, so no process
-- starts per keypress. The Omarchy menu is reachable from oma-cast ("Omarchy Menu").
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "oma-cast launcher", hl.dsp.global("oma-cast:toggle"))

-- Pop instantly, like Omarchy's own overlays, instead of the compositor layer fade.
hl.layer_rule({ match = { namespace = "oma-cast" }, no_anim = true, animation = "none" })


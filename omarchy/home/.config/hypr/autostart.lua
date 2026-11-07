-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- XWayland apps render unscaled (force_zero_scaling); Xft.dpi 160 matches the 1.67x display.
o.exec_on_start("xrdb -merge ~/.Xresources")

local wezterm = require 'wezterm';
return {
	font = wezterm.font("IBM Plex Mono"),
	font_size = 13,
	color_scheme = "AtomOneLight",
	use_ime = true,
  window_frame = {

    font = wezterm.font({family="IBM Plex Sans", weight="Bold"}),
    font_size = 13.0,
    active_titlebar_bg = "#f4f4f4",
    inactive_titlebar_bg = "#333333",
  },
  launch_menu = {
        {
          label = "Plan9",
          args = {"/usr/local/plan9/bin/rc","-l"},
        },
    },
  enable_wayland = true,
}

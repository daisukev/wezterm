local wezterm = require("wezterm")

local act = wezterm.action

local config = wezterm.config_builder()

config.term = "wezterm"

local appearance = require("appearance")

local nvim = require("nvim-server")

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.color_scheme = appearance.scheme_for_appearance(appearance.get_appearance())

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	-- local appearance = appearance.get_appearance()
	local scheme = appearance.scheme_for_appearance(appearance)

	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

config.font = wezterm.font_with_fallback({
	"Liga SFMono Nerd Font",
	"Fira Code",
	"DengXian",
	"Courier New",
})
config.font_size = 15.0

-- Keep the window borders for resizing
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 80

config.window_frame = {
	font_size = 16.0,
	active_titlebar_bg = "#111",
}

-- config.use_fancy_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true
--
wezterm.on("update-status", function(window)
	-- Grab the utf8 character for the "powerline" left facing
	-- solid arrow.
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Grab the current window's configuration, and from it the
	-- palette (this is the combination of your chosen colour scheme
	-- including any overrides).
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground

	window:set_right_status(wezterm.format({
		-- First, we draw the arrow...
		{ Background = { Color = "none" } },
		{ Foreground = { Color = bg } },
		{ Text = SOLID_LEFT_ARROW },
		-- Then we draw our text
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. wezterm.hostname() .. " " },
	}))
end)
-- Tab Bar config
--

local function move_pane(key, direction)
	return {
		key = key,
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

-- keybindings
config.keys = {
	{
		key = "t",
		mods = "CMD|SHIFT",
		action = act.ShowTabNavigator,
	},
	{
		key = "R",
		mods = "CMD|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = ",",
		mods = "CMD",
		action = act.SpawnCommandInNewWindow({
			cwd = os.getenv("WEZTERM_CONFIG_DIR"),
			set_environment_variables = {
				-- TERM = "screen-256color",
			},
			args = {
				-- tostring(nvim.run_command("command -v nvim")[1]) or 			-- "/usr/local/bin/nvim",
				"/opt/homebrew/bin/nvim",
				-- nvim.run_command("command -v nvim")
				os.getenv("WEZTERM_CONFIG_FILE"),
			},
		}),
	},
	-- Sends ESC + b and ESC + f sequence, which is used
	-- for telling your shell to jump back/forward.
	{
		-- When the left arrow is pressed
		key = "LeftArrow",
		-- With the "Option" key modifier held down
		mods = "OPT",
		-- Perform this action, in this case - sending ESC + B
		-- to the terminal
		action = wezterm.action.SendString("\x1bb"),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bf"),
	},
	{
		-- I'm used to tmux bindings, so am using the quotes (") key to
		-- split horizontally, and the percent (%) key to split vertically.
		key = "\\",
		-- Note that instead of a key modifier mapped to a key on your keyboard
		-- like CTRL or ALT, we can use the LEADER modifier instead.
		-- This means that this binding will be invoked when you press the leader
		-- (CTRL + A), quickly followed by quotes (").
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "a",
		-- When we're in leader mode _and_ CTRL + A is pressed...
		mods = "LEADER|CTRL",
		-- Actually send CTRL + A key to the terminal
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},

	move_pane("j", "Down"),
	move_pane("k", "Up"),
	move_pane("h", "Left"),
	move_pane("l", "Right"),
	{
		-- When we push LEADER + R...
		key = "r",
		mods = "LEADER",
		-- Activate the `resize_panes` keytable
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			-- Ensures the keytable stays active after it handles its
			-- first keypress.
			one_shot = false,
			-- Deactivate the keytable after a timeout.
			timeout_milliseconds = 1000,
		}),
	},
}

-- load nvim keybinds
for _, keybind in ipairs(nvim.keys) do
	table.insert(config.keys, keybind)
end

config.key_tables = {
	resize_panes = {
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("h", "Left"),
		resize_pane("l", "Right"),
	},
}
return config

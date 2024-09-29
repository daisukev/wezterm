local wezterm = require("wezterm")

local nvim = require("nvim-server")
local module = {}
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function module.get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function module.scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		nvim.set_colorscheme("kanagawa-wave")
		-- return "Builtin Solarized Dark"
		return "Kanagawa (Gogh)"
	else
		-- return "Alabaster"
		-- return "Atelier Estuary Light (base16)"
		-- return "Atelier Forest Light (base16)"
		-- return "AtomOneLight"
		-- return "ayu_light"
		-- return "Belafonte Day (Gogh)"
		-- return "Builtin Tango Light"
		-- return "Catppuccin Latte"
		nvim.set_colorscheme("base16-classic-light", "light")
		return "Classic Light (base16)"
	end
end
-- font
return module

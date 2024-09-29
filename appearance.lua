local wezterm = require("wezterm")

local nvim = require("nvim-server")
local module = {}
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function module.get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()

		-- fallback for macos if you can't fetch the appearance through mux
		-- elseif wezterm.target_triple == "aarch64-apple-darwin" then
		-- 	local success, stdout, stderr = wezterm.run_child_process({ "defaults", "read", "-g", "AppleInterfaceStyle" })
		-- 	if string.find(stdout, "Dark") then
		-- 		return "Dark"
		-- 	else
		-- 		return "Light"
		-- 	end
	end
	-- default to dark
	return "Dark"
end

function module.scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		nvim.set_colorscheme("kanagawa-wave")
		return "Kanagawa (Gogh)"
	else
		nvim.set_colorscheme("base16-classic-light", "light")
		return "Classic Light (base16)"
	end
end
return module

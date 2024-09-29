local wezterm = require("wezterm")
local module = {}

local home_dir = os.getenv("HOME")

local db_path = home_dir .. "/.config/nvim/db/servers.db"

function module.run_command(command)
	local handle = io.popen(command)
	local output = {}
	if handle ~= nil then
		for line in handle:lines() do
			table.insert(output, line)
		end
		handle:close()
		return output
	end
end
function module.sql_exec(query)
	local command = string.format('sqlite3 %s "%s"', db_path, query)
	local res = module.run_command(command)
	return res
end

function module.get_servers()
	local servers = module.sql_exec("SELECT SERVER_NAME FROM SERVERS;")
	return servers
end

function module.nvim_exec(command)
	local output = module.run_command("command -v nvim")
	local nvim_path = output[1] or "/opt/homebrew/bin/nvim"
	local servers = module.get_servers()

	if servers ~= nil then
		for _, server in ipairs(servers) do
			local fCommand = string.format('%s --server "%s" --remote-send "%s"', nvim_path, server, command)

			os.execute(fCommand)
		end
	end
end

function module.set_colorscheme(colorscheme, brightness)
	local cmd
	if brightness == "light" then
		module.sql_exec("UPDATE SYSTEM_APPEARANCE SET COLOR_MODE = 'light';")
		cmd = string.format(":colorscheme %s|set background=light<CR>", colorscheme)
	else
		module.sql_exec("UPDATE SYSTEM_APPEARANCE SET COLOR_MODE = 'dark';")
		cmd = string.format(":colorscheme %s|set background=dark<CR>", colorscheme)
	end
	if cmd ~= nil then
		module.nvim_exec(cmd)
	end
end

module.keys = {
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			module.set_colorscheme("randomhue")
		end),
	},
}

return module

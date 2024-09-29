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
function module.exec(query)
	local command = string.format("sqlite3 %s '%s'", db_path, query)

	-- window:toast_notification("wezterm", "configuration reloaded!", nil, 4000)
	-- window:set_left_status("")
	--
	local res = module.run_command(command)
	return res
end

function module.get_servers()
	local servers = module.exec("SELECT SERVER_NAME FROM SERVERS;")
	return servers
end

function module.nvim_exec(command, window)
	local output = module.run_command("command -v nvim")
	local nvim_path = output[1] or "/opt/homebrew/bin/nvim"
	local servers = module.get_servers()

	if servers ~= nil then
		for _, server in ipairs(servers) do
			local fCommand = string.format("%s --server '%s' --remote-send '%s'", nvim_path, server, command)
			window:toast_notification("wezterm", fCommand, nil, 4000)
			-- local res = module.run_command(fCommand)
			--
			-- local logOut = res[1] or "NOTHING"

			os.execute(fCommand)
		end
	else
		window:toast_notification("wezterm", "servers nil", nil, 4000)
	end
end

return module

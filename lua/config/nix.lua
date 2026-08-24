local info = require(vim.g.nix_info_plugin_name)

local M = {}

function M.setting(name, default)
	local value = info.settings[name]
	if value == nil then
		return default
	end
	return value
end

function M.spec_enabled(name)
	return info(false, "info", "specs", name)
end

return M

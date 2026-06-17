if mnw ~= nil then
	local config_path = mnw.configDir .. "/pack/mnw/start/ben"
	if (vim.uv or vim.loop).fs_stat(config_path) then
		vim.cmd("packadd! ben")
	end
end

require("config.lazy")

local nix = require("config.nix")

local plugins = {
	{ import = "plugins.ui" },
	{ import = "plugins.editor" },
	{ import = "plugins.coding" },
	{ import = "plugins.treesitter" },
}

for _, spec in ipairs({
	"lsp",
	"languages",
	"debugging",
	"formatting",
	"linting",
	"ai",
}) do
	if nix.spec_enabled(spec) then
		table.insert(plugins, { import = "plugins." .. spec })
	end
end

return plugins

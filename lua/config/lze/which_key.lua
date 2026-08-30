local plugins = {}

local handler = {
	spec_field = "which_key",
	set_lazy = false,
}

local function plugin_icon(name)
	local config = require("which-key.config")
	local icons = require("which-key.icons")

	local rule_sets = {
		config.icons.rules,
		icons.rules,
	}

	for _, rules in ipairs(rule_sets) do
		if type(rules) == "table" then
			for _, rule in ipairs(rules) do
				if rule.plugin == name and icons.get_icon(rule) then
					return vim.deepcopy(rule)
				end
			end
		end
	end

	local icon = {
		cat = "filetype",
		name = name,
	}

	if icons.get_icon(icon) then
		return icon
	end
end

function handler.add(plugin)
	if not plugin.keys then
		return
	end

	plugins[#plugins + 1] = {
		name = type(plugin.which_key) == "string" and plugin.which_key or plugin.name,
		keys = plugin.keys,
	}
end

handler.lib = {
	register = function()
		local which_key = require("which-key")
		local parse = require("lze").h.keys.parse

		for _, plugin in ipairs(plugins) do
			local icon = plugin_icon(plugin.name)

			if icon then
				local keys = type(plugin.keys) == "string" and { plugin.keys } or plugin.keys
				local specs = {}

				for _, key in ipairs(keys) do
					for _, parsed in ipairs(parse(key)) do
						specs[#specs + 1] = {
							parsed.lhs,
							mode = parsed.mode,
							icon = vim.deepcopy(icon),
						}
					end
				end

				which_key.add(specs)
			end
		end
	end,
}

return handler

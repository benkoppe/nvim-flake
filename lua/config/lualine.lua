local M = {}

local root = require("config.root")

local function format(component, text, highlight)
	text = text:gsub("%%", "%%%%")

	if not highlight or highlight == "" then
		return text
	end

	component.highlight_cache = component.highlight_cache or {}

	local lualine_highlight = component.highlight_cache[highlight]
	if not lualine_highlight then
		local utils = require("lualine.utils.utils")
		local gui = vim.tbl_filter(function(value)
			return value
		end, {
			utils.extract_highlight_colors(highlight, "bold") and "bold",
			utils.extract_highlight_colors(highlight, "italic") and "italic",
		})

		lualine_highlight = component:create_hl({
			fg = utils.extract_highlight_colors(highlight, "fg"),
			gui = #gui > 0 and table.concat(gui, ",") or nil,
		}, "Config_" .. highlight)

		component.highlight_cache[highlight] = lualine_highlight
	end

	return component:format_hl(lualine_highlight) .. text .. component:get_default_hl()
end

function M.pretty_path()
	return function(component)
		local path = vim.fn.expand("%:p")

		if path == "" then
			return ""
		end

		path = vim.fs.normalize(path)

		local cwd = vim.fs.normalize(vim.uv.cwd())
		local project_root = vim.fs.normalize(root())

		if vim.startswith(path, cwd .. "/") then
			path = path:sub(#cwd + 2)
		elseif vim.startswith(path, project_root .. "/") then
			path = path:sub(#project_root + 2)
		end

		local separator = package.config:sub(1, 1)
		local parts = vim.split(path, "[\\/]")

		if #parts > 3 then
			parts = {
				parts[1],
				"…",
				unpack(parts, #parts - 1, #parts),
			}
		end

		local filename = parts[#parts]

		if vim.bo.modified then
			filename = format(component, filename, "MatchParen")
		else
			filename = format(component, filename, "Bold")
		end

		local directory = ""
		if #parts > 1 then
			directory = table.concat({
				unpack(parts, 1, #parts - 1),
			}, separator) .. separator
		end

		local readonly = ""
		if vim.bo.readonly then
			readonly = format(component, " 󰌾 ", "MatchParen")
		end

		return directory .. filename .. readonly
	end
end

return M

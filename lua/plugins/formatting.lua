local web_filetypes = {
	"css",
	"graphql",
	"handlebars",
	"html",
	"javascript",
	"javascriptreact",
	"json",
	"jsonc",
	"less",
	"markdown",
	"markdown.mdx",
	"scss",
	"svelte",
	"typescript",
	"typescriptreact",
	"vue",
	"yaml",
}

local function web_formatter(buffer)
	local filename = vim.api.nvim_buf_get_name(buffer)
	local directory = vim.fs.dirname(filename)

	if not directory or directory == "" then
		directory = vim.uv.cwd()
	end

	if vim.fs.root(directory, { ".oxfmtrc.json", ".oxfmtrc.jsonc" }) then
		return { "oxfmt" }
	end

	return { "prettierd" }
end

local function format_enabled(buffer)
	buffer = buffer == 0 and vim.api.nvim_get_current_buf() or buffer

	if vim.b[buffer].autoformat ~= nil then
		return vim.b[buffer].autoformat
	end

	return vim.g.autoformat ~= false
end

local function format_options(buffer)
	if not format_enabled(buffer) then
		return
	end

	return {
		timeout_ms = 3000,
		lsp_format = "fallback",
	}
end

return {
	{
		"conform.nvim",
		lazy = false,
		after = function()
			local conform = require("conform")

			local formatters_by_ft = {
				lua = { "stylua" },
				fish = { "fish_indent" },
				sh = { "shfmt" },

				python = { "black" },

				go = {
					"goimports",
					"gofumpt",
				},

				haskell = { "fourmolu" },
				cabal = { "cabal_fmt" },

				kotlin = { "ktlint" },
				nix = { "nixfmt" },
				ruby = { "rubocop" },

				sql = { "sqlfluff" },
				mysql = { "sqlfluff" },
				plsql = { "sqlfluff" },
			}

			for _, filetype in ipairs(web_filetypes) do
				formatters_by_ft[filetype] = web_formatter
			end

			conform.setup({
				default_format_opts = {
					timeout_ms = 3000,
					async = false,
					quiet = false,
					lsp_format = "fallback",
				},
				format_on_save = format_options,
				formatters_by_ft = formatters_by_ft,
				formatters = {
					injected = {
						options = {
							ignore_errors = true,
						},
					},
					nixfmt = {
						append_args = { "-" },
					},
					sqlfluff = {
						args = {
							"format",
							"--dialect=ansi",
							"-",
						},
						require_cwd = false,
					},
				},
			})

			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

			vim.keymap.set({ "n", "x" }, "<leader>cf", function()
				conform.format({
					timeout_ms = 3000,
					lsp_format = "fallback",
				})
			end, {
				desc = "Format",
			})

			vim.keymap.set({ "n", "x" }, "<leader>cF", function()
				conform.format({
					formatters = { "injected" },
					timeout_ms = 3000,
				})
			end, {
				desc = "Format injected languages",
			})

			Snacks.toggle({
				name = "Auto format (global)",
				get = function()
					return vim.g.autoformat ~= false
				end,
				set = function(enabled)
					vim.g.autoformat = enabled
					vim.b.autoformat = nil
				end,
			}):map("<leader>uf")

			Snacks.toggle({
				name = "Auto format (buffer)",
				get = function()
					return format_enabled(0)
				end,
				set = function(enabled)
					vim.b.autoformat = enabled
				end,
			}):map("<leader>uF")
		end,
	},
}

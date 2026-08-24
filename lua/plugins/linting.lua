return {
	{
		"nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				nix = { "deadnix", "statix" },
				sh = { "shellcheck" },
				go = { "golangcilint" },
				haskell = { "hlint" },
				kotlin = { "ktlint" },
				markdown = { "markdownlint-cli2" },
				sql = { "sqlfluff" },
				mysql = { "sqlfluff" },
				plsql = { "sqlfluff" },
				php = { "phpcs" },
			}

			-- Match the ANSI fallback used by our conform configuration.
			lint.linters.sqlfluff.args = {
				"lint",
				"--format=json",
				"--dialect=ansi",
				"-",
			}

			local group = vim.api.nvim_create_augroup("config_lint", {
				clear = true,
			})

			vim.api.nvim_create_autocmd({
				"BufReadPost",
				"BufWritePost",
				"InsertLeave",
			}, {
				group = group,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}

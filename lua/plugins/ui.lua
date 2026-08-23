local root = require("config.root")

return {
	{
		"mini.icons",
		lazy = false,
		after = function()
			require("mini.icons").setup()
			MiniIcons.mock_nvim_web_devicons()
		end,
	},

	{
		"snacks.nvim",
		lazy = false,
		priority = 1000,
		keys = {
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Notification history",
			},
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss notifications",
			},
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle scratch buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select scratch buffer",
			},
		},
		after = function()
			require("snacks").setup({
				bigfile = {},
				dashboard = {
					sections = {
						{ section = "header" },
						{ section = "keys", gap = 1, padding = 1 },
					},
					preset = {
						keys = {
							{
								icon = " ",
								key = "f",
								desc = "Find file",
								action = ":FzfLua files",
							},
							{
								icon = " ",
								key = "n",
								desc = "New file",
								action = ":ene | startinsert",
							},
							{
								icon = " ",
								key = "g",
								desc = "Find text",
								action = ":FzfLua live_grep",
							},
							{
								icon = " ",
								key = "r",
								desc = "Recent files",
								action = ":FzfLua oldfiles",
							},
							{
								icon = " ",
								key = "s",
								desc = "Restore session",
								action = ":lua require('lze').trigger_load('persistence.nvim'); require('persistence').load()",
							},
							{
								icon = " ",
								key = "q",
								desc = "Quit",
								action = ":qa",
							},
						},
					},
				},
				indent = {},
				input = {},
				notifier = {},
				quickfile = {},
				scope = {},
				scroll = {
					enabled = false,
				},
				statuscolumn = {
					folds = {
						open = false,
						git_hl = false,
					},
					git = {
						patterns = {
							"GitSign",
							"MiniDiffSign",
						},
					},
					refresh = 50,
				},
				terminal = {},
				words = {},
			})

			vim.o.statuscolumn = "%!v:lua.Snacks.statuscolumn()"

			vim.keymap.set("n", "<leader>gg", function()
				Snacks.lazygit({ cwd = root.git() })
			end, { desc = "Lazygit (root)" })

			vim.keymap.set("n", "<leader>gG", function()
				Snacks.lazygit()
			end, { desc = "Lazygit (cwd)" })

			vim.keymap.set({ "n", "x" }, "<leader>gB", function()
				Snacks.gitbrowse()
			end, { desc = "Open in browser" })

			vim.keymap.set({ "n", "x" }, "<leader>gY", function()
				Snacks.gitbrowse({
					open = function(url)
						vim.fn.setreg("+", url)
					end,
					notify = false,
				})
			end, { desc = "Copy Git URL" })

			vim.keymap.set("n", "<leader>ft", function()
				Snacks.terminal(nil, { cwd = root() })
			end, { desc = "Terminal (root)" })

			Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
			Snacks.toggle.zen():map("<leader>uz")

			Snacks.toggle
				.option("showtabline", {
					off = 0,
					on = vim.o.showtabline > 0 and vim.o.showtabline or 2,
					name = "Tabline",
				})
				:map("<leader>uA")

			Snacks.toggle.treesitter():map("<leader>uT")
			Snacks.toggle
				.option("background", {
					off = "light",
					on = "dark",
					name = "Dark background",
				})
				:map("<leader>ub")

			Snacks.toggle.dim():map("<leader>uD")
			Snacks.toggle.animate():map("<leader>ua")
			Snacks.toggle.indent():map("<leader>ug")
			Snacks.toggle.scroll():map("<leader>uS")
			Snacks.toggle.profiler():map("<leader>dpp")
			Snacks.toggle.profiler_highlights():map("<leader>dph")
		end,
	},

	{
		"tokyonight.nvim",
		lazy = false,
		priority = 1000,
		after = function()
			require("tokyonight").setup({
				style = "moon",
			})

			vim.cmd.colorscheme("tokyonight")
		end,
	},

	{
		"lualine.nvim",
		event = "DeferredUIEnter",
		after = function()
			local trouble = require("trouble")
			local symbols = trouble.statusline({
				mode = "symbols",
				groups = {},
				title = false,
				filter = {
					range = true,
				},
				format = "{kind_icon}{symbol.name:Normal}",
				hl_group = "lualine_c_normal",
			})

			require("lualine").setup({
				options = {
					globalstatus = true,
					theme = "auto",
					disabled_filetypes = {
						statusline = {
							"dashboard",
							"alpha",
							"ministarter",
							"snacks_dashboard",
						},
					},
					component_separators = {
						left = "│",
						right = "│",
					},
					section_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						{
							"diff",
							source = function()
								local summary = vim.b.minidiff_summary

								return summary
									and {
										added = summary.add,
										modified = summary.change,
										removed = summary.delete,
									}
							end,
						},
					},
					lualine_c = {
						{
							function()
								return "󱉭 " .. vim.fn.fnamemodify(root(), ":t")
							end,
							cond = function()
								return root() ~= vim.uv.cwd()
							end,
						},
						{
							"diagnostics",
							symbols = {
								error = " ",
								warn = " ",
								info = " ",
								hint = " ",
							},
						},
						{
							"filetype",
							icon_only = true,
							separator = "",
							padding = {
								left = 1,
								right = 0,
							},
						},
						{
							require("config.lualine").pretty_path(),
						},
						{
							symbols.get,
							cond = function()
								return vim.b.trouble_lualine ~= false and symbols.has()
							end,
						},
					},
					lualine_x = {
						Snacks.profiler.status(),
						{
							function()
								return "  " .. require("dap").status()
							end,
							cond = function()
								return package.loaded.dap and require("dap").status() ~= ""
							end,
							color = function()
								return {
									fg = Snacks.util.color("Debug"),
								}
							end,
						},
					},
					lualine_y = {
						"progress",
					},
					lualine_z = {
						"location",
					},
				},
				extensions = {
					"neo-tree",
					"fzf",
				},
			})
		end,
	},

	{
		"which-key.nvim",
		event = "DeferredUIEnter",
		after = function()
			local which_key = require("which-key")

			which_key.setup({
				preset = "helix",
			})

			require("lze").h.which_key.register()

			which_key.add({
				{ "<leader><tab>", group = "tabs" },
				{ "<leader>b", group = "buffers" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>f", group = "file/find" },
				{ "<leader>g", group = "git" },
				{ "<leader>o", group = "opencode" },
				{ "<leader>q", group = "quit/session" },
				{ "<leader>s", group = "search" },
				{ "<leader>u", group = "UI" },
				{ "<leader>w", group = "windows" },
				{ "<leader>x", group = "diagnostics/quickfix" },
				{ "[", group = "previous" },
				{ "]", group = "next" },
				{ "g", group = "goto" },
				{ "gs", group = "surround" },
				{ "z", group = "fold" },
			})

			vim.keymap.set("n", "<leader>?", function()
				which_key.show({ global = false })
			end, { desc = "Buffer-local keymaps" })

			vim.keymap.set("n", "<C-w><Space>", function()
				which_key.show({
					keys = "<C-w>",
					loop = true,
				})
			end, { desc = "Window hydra" })
		end,
	},

	{
		"persistence.nvim",
		event = "BufReadPre",
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Restore session",
			},
			{
				"<leader>qS",
				function()
					require("persistence").select()
				end,
				desc = "Select session",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore last session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Stop saving session",
			},
		},
		after = function()
			require("persistence").setup()
		end,
	},
}

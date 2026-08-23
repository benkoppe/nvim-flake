local opencode_command = "opencode --port"

local terminal_options = {
	win = {
		position = "right",
		enter = false,
	},
}

return {
	{
		"opencode.nvim",
		on_require = "opencode",
		keys = {
			{
				"<leader>o?",
				function()
					require("opencode").ask("@this: ")
				end,
				mode = { "n", "x" },
				desc = "Ask opencode",
			},
			{
				"<leader>ox",
				function()
					require("opencode").select()
				end,
				mode = { "n", "x" },
				desc = "Select opencode action",
			},
			{
				"<leader>oa",
				function()
					require("opencode").prompt("@this")
				end,
				mode = { "n", "x" },
				desc = "Add to opencode",
			},
			{
				"<leader>oo",
				function()
					require("snacks.terminal").toggle(opencode_command, terminal_options)
				end,
				desc = "Toggle opencode",
			},
			{
				"<leader>os",
				function()
					require("opencode").command("session.interrupt")
				end,
				desc = "Interrupt opencode",
			},
			{
				"<S-C-u>",
				function()
					require("opencode").command("session.half.page.up")
				end,
				desc = "Scroll opencode up",
			},
			{
				"<S-C-d>",
				function()
					require("opencode").command("session.half.page.down")
				end,
				desc = "Scroll opencode down",
			},
		},
		before = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {
				server = {
					start = function()
						require("snacks.terminal").open(opencode_command, terminal_options)
					end,
				},
			}

			vim.o.autoread = true

			vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
				desc = "Exit terminal mode",
			})
		end,
	},
}

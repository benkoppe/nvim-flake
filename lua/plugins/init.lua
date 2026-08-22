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
		after = function()
			require("snacks").setup({
				bigfile = {},
				input = {},
				notifier = {},
				quickfile = {},
				scope = {},
				terminal = {},
				words = {},
			})
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
}

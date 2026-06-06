-- for disabling built-in LazyVim plugins
return {
	-- disable bufferline.nvim
	{ "akinsho/bufferline.nvim", enabled = false },

	-- disable noice.nvim cmdline replacement
	{ "folke/noice.nvim", enabled = false },

	-- disable yanky sync with system
	{ "gbprod/yanky.nvim", opts = {
		system_clipboard = {
			sync_with_ring = false,
		},
	} },
}

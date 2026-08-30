vim.loader.enable()

vim.keymap.set("n", " ", "<Nop>", {
	silent = true,
	remap = false,
})

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.filetypes")
require("config.autocmds")

local lze = require("lze")
lze.register_handlers(require("config.lze.which_key"))
lze.load("plugins")

require("config.keymaps")

return {
	{
		"SchemaStore.nvim",
		on_require = "schemastore",
	},

	{
		"crates.nvim",
		event = "BufRead Cargo.toml",
		after = function()
			require("crates").setup({
				completion = {
					crates = {
						enabled = true,
					},
				},
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
			})
		end,
	},

	{
		"rustaceanvim",
		lazy = false,
		before = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(_, buffer)
						vim.keymap.set("n", "<leader>cR", function()
							vim.cmd.RustLsp("codeAction")
						end, {
							buffer = buffer,
							desc = "Rust code action",
						})
					end,
					default_settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								targetDir = "target/rust-analyzer",
								buildScripts = {
									enable = true,
								},
							},
							checkOnSave = true,
							diagnostics = {
								enable = true,
							},
							procMacro = {
								enable = true,
							},
							files = {
								exclude = {
									".direnv",
									".git",
									".jj",
									".github",
									".gitlab",
									"bin",
									"node_modules",
									"target",
									"venv",
									".venv",
								},
								watcher = "client",
							},
						},
					},
				},
			}
		end,
	},

	{
		"vimtex",
		lazy = false,
		before = function()
			vim.g.vimtex_mappings_disable = {
				n = { "K" },
			}

			vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
		end,
		keys = {
			{
				"<leader>K",
				"<Plug>(vimtex-doc-package)",
				ft = { "tex", "plaintex", "bib" },
				remap = true,
				silent = true,
				desc = "VimTeX docs",
			},
		},
	},
}

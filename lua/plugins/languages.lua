local with_after = require("lzextras").loaders.with_after

local sql_filetypes = {
	"sql",
	"mysql",
	"plsql",
}

-- Disable Neovim's legacy SQL completion while retaining syntax keywords.
vim.g.omni_sql_default_compl_type = "syntax"
vim.g.loaded_sql_completion = true

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

	{
		"markdown-preview.nvim",
		cmd = {
			"MarkdownPreview",
			"MarkdownPreviewStop",
			"MarkdownPreviewToggle",
		},
		keys = {
			{
				"<leader>cp",
				"<cmd>MarkdownPreviewToggle<cr>",
				ft = { "markdown", "markdown.mdx" },
				desc = "Markdown preview",
			},
		},
		after = function()
			-- The plugin was loaded after the original FileType event.
			vim.cmd("doautocmd FileType")
		end,
	},

	{
		"render-markdown.nvim",
		ft = { "markdown", "markdown.mdx" },
		after = function()
			local render_markdown = require("render-markdown")

			render_markdown.setup({
				code = {
					sign = false,
					width = "block",
					right_pad = 1,
				},
				heading = {
					sign = false,
					icons = {},
				},
				checkbox = {
					enabled = false,
				},
			})

			Snacks.toggle({
				name = "Render Markdown",
				get = render_markdown.get,
				set = render_markdown.set,
			}):map("<leader>um")
		end,
	},

	{
		"cmake-tools.nvim",
		cmd = {
			"CMakeGenerate",
			"CMakeClean",
			"CMakeBuild",
			"CMakeQuickBuild",
			"CMakeInstall",
			"CMakeStopExecutor",
			"CMakeStopRunner",
			"CMakeCloseExecutor",
			"CMakeCloseRunner",
			"CMakeOpenExecutor",
			"CMakeOpenRunner",
			"CMakeOpenCache",
			"CMakeRun",
			"CMakeQuickRun",
			"CMakeRunCurrentFile",
			"CMakeBuildCurrentFile",
			"CMakeLaunchArgs",
			"CMakeSelectBuildType",
			"CMakeSelectKit",
			"CMakeSelectConfigurePreset",
			"CMakeSelectBuildPreset",
			"CMakeSelectTestPreset",
			"CMakeSelectBuildTarget",
			"CMakeSelectLaunchTarget",
			"CMakeTargetSettings",
			"CMakeSettings",
			"CMakeSelectCwd",
			"CMakeSelectBuildDir",
			"CMakeRunTest",
			"CMakeQuickStart",
		},
		beforeAll = function()
			local loaded = false

			local function load_for_project()
				if loaded then
					return
				end

				local cmake_lists = vim.fs.joinpath(vim.uv.cwd(), "CMakeLists.txt")

				if vim.fn.filereadable(cmake_lists) == 1 then
					loaded = true
					require("lze").trigger_load("cmake-tools.nvim")
				end
			end

			load_for_project()

			vim.api.nvim_create_autocmd("DirChanged", {
				group = vim.api.nvim_create_augroup("config_cmake_tools", {
					clear = true,
				}),
				callback = load_for_project,
			})
		end,
		after = function()
			require("cmake-tools").setup({})
		end,
	},

	{
		"clangd_extensions.nvim",
		ft = { "c", "cpp", "objc", "objcpp" },
		on_require = "clangd_extensions",
		after = function()
			require("clangd_extensions").setup({
				ast = {
					role_icons = {
						type = "",
						declaration = "",
						expression = "",
						specifier = "",
						statement = "",
						["template argument"] = "",
					},
					kind_icons = {
						Compound = "",
						Recovery = "",
						TranslationUnit = "",
						PackExpansion = "",
						TemplateTypeParm = "",
						TemplateTemplateParm = "",
						TemplateParamObject = "",
					},
				},
			})
		end,
	},

	{
		"venv-selector.nvim",
		cmd = "VenvSelect",
		ft = "python",
		keys = {
			{
				"<leader>cv",
				"<cmd>VenvSelect<cr>",
				ft = "python",
				desc = "Select virtual environment",
			},
		},
		after = function()
			require("venv-selector").setup({
				options = {
					picker = "fzf-lua",
					notify_user_on_venv_activation = true,
					override_notify = false,
				},
			})
		end,
	},

	{
		"vim-dadbod",
		cmd = "DB",
		dep_of = {
			"vim-dadbod-ui",
			"vim-dadbod-completion",
		},
	},

	{
		"vim-dadbod-completion",
		ft = sql_filetypes,
		load = with_after,
		before = function()
			-- Its after/plugin script registers directly with nvim-cmp.
			require("lze").trigger_load("nvim-cmp")
		end,
		after = function()
			local cmp = require("cmp")
			local sources = vim.deepcopy(cmp.get_config().sources)

			table.insert(sources, {
				name = "vim-dadbod-completion",
			})

			cmp.setup.filetype(sql_filetypes, {
				sources = sources,
			})
		end,
	},

	{
		"vim-dadbod-ui",
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		keys = {
			{
				"<leader>D",
				"<cmd>DBUIToggle<cr>",
				desc = "Toggle database UI",
			},
		},
		before = function()
			local data_path = vim.fn.stdpath("data")

			vim.g.db_ui_auto_execute_table_helpers = 1
			vim.g.db_ui_execute_on_save = false
			vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
			vim.g.db_ui_show_database_icon = true
			vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
			vim.g.db_ui_use_nerd_fonts = true
			vim.g.db_ui_use_nvim_notify = true
		end,
	},
}

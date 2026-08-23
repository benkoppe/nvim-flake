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
}

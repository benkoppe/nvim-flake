local M = {}

local servers = {
	"basedpyright",
	"bashls",
	"clangd",
	"cssls",
	"denols",
	"docker_compose_language_service",
	"dockerls",
	"gopls",
	"html",
	"jsonls",
	"kotlin_language_server",
	"nixd",
	"nushell",
	"ocamllsp",
	"phpactor",
	"prismals",
	"rubocop",
	"ruff",
	"sourcekit",
	"svelte",
	"tailwindcss",
	"taplo",
	"texlab",
	"vtsls",
	"vue_ls",
	"yamlls",
	"zls",
}

function M.setup()
	vim.lsp.config("clangd", {
		root_markers = {
			"compile_commands.json",
			"compile_flags.txt",
			"configure.ac",
			"Makefile",
			"configure.in",
			"config.h.in",
			"meson.build",
			"meson_options.txt",
			"build.ninja",
			".git",
		},
		capabilities = {
			offsetEncoding = { "utf-16" },
		},
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders",
			"--fallback-style=llvm",
		},
		init_options = {
			usePlaceholders = true,
			completeUnimported = true,
			clangdFileStatus = true,
		},
	})

	vim.lsp.config("gopls", {
		init_options = {
			semanticTokens = true,
		},
		settings = {
			gopls = {
				gofumpt = true,
				codelenses = {
					gc_details = false,
					generate = true,
					regenerate_cgo = true,
					run_govulncheck = true,
					test = true,
					tidy = true,
					upgrade_dependency = true,
					vendor = true,
				},
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				analyses = {
					nilness = true,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
				},
				usePlaceholders = true,
				completeUnimported = true,
				staticcheck = true,
				directoryFilters = {
					"-.git",
					"-.vscode",
					"-.idea",
					"-.vscode-test",
					"-node_modules",
				},
			},
		},
	})

	vim.lsp.config("ruff", {
		cmd_env = {
			RUFF_TRACE = "messages",
		},
		init_options = {
			settings = {
				logLevel = "error",
			},
		},
		on_attach = function(client)
			-- BasedPyright provides the more useful Python hover response.
			client.server_capabilities.hoverProvider = false
		end,
	})

	vim.lsp.config("jsonls", {
		before_init = function(_, config)
			config.settings.json.schemas = config.settings.json.schemas or {}
			vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
		end,
		settings = {
			json = {
				format = {
					enable = true,
				},
				validate = {
					enable = true,
				},
			},
		},
	})

	vim.lsp.config("yamlls", {
		capabilities = {
			textDocument = {
				foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				},
			},
		},
		before_init = function(_, config)
			config.settings.yaml.schemas =
				vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
		end,
		settings = {
			redhat = {
				telemetry = {
					enabled = false,
				},
			},
			yaml = {
				keyOrdering = false,
				format = {
					enable = true,
				},
				validate = true,
				schemaStore = {
					enable = false,
					url = "",
				},
			},
		},
	})

	local tailwind_filetypes = vim.tbl_filter(function(filetype)
		return filetype ~= "markdown"
	end, vim.deepcopy(vim.lsp.config.tailwindcss.filetypes))

	vim.lsp.config("tailwindcss", {
		filetypes = tailwind_filetypes,
	})

	-- sourcekit-lsp also advertises C and C++ support, but clangd owns those.
	vim.lsp.config("sourcekit", {
		filetypes = { "swift" },
	})

	local vue_language_server = vim.fn.exepath("vue-language-server")
	local vue_package = vim.fs.dirname(vim.fs.dirname(vue_language_server))
	local vue_plugin_location = vue_package .. "/lib/language-tools/packages/language-server"

	local vtsls_filetypes = vim.deepcopy(vim.lsp.config.vtsls.filetypes)
	table.insert(vtsls_filetypes, "vue")

	vim.lsp.config("vtsls", {
		filetypes = vtsls_filetypes,
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_plugin_location,
							languages = { "vue" },
							configNamespace = "typescript",
							enableForWorkspaceTypeScriptVersions = true,
						},
					},
				},
			},
		},
	})

	return servers
end

return M

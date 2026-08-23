local function fzf_picker(name, opts)
	return function()
		require("lze").trigger_load("fzf-lua")
		require("fzf-lua")[name](opts or {})
	end
end

local function supports(client, method, buffer)
	return client:supports_method(method, buffer)
end

local function set_lsp_keymaps(client, buffer)
	local function map(method, mode, lhs, rhs, desc, opts)
		if method and not supports(client, method, buffer) then
			return
		end

		vim.keymap.set(
			mode,
			lhs,
			rhs,
			vim.tbl_extend("force", {
				buffer = buffer,
				silent = true,
				desc = desc,
			}, opts or {})
		)
	end

	map(nil, "n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP information")

	map(
		"textDocument/definition",
		"n",
		"gd",
		fzf_picker("lsp_definitions", {
			jump1 = true,
			ignore_current_line = true,
		}),
		"Goto definition"
	)

	map(
		"textDocument/references",
		"n",
		"gr",
		fzf_picker("lsp_references", {
			jump1 = true,
			ignore_current_line = true,
		}),
		"References",
		{ nowait = true }
	)

	map(
		"textDocument/implementation",
		"n",
		"gI",
		fzf_picker("lsp_implementations", {
			jump1 = true,
			ignore_current_line = true,
		}),
		"Goto implementation"
	)

	map(
		"textDocument/typeDefinition",
		"n",
		"gy",
		fzf_picker("lsp_typedefs", {
			jump1 = true,
			ignore_current_line = true,
		}),
		"Goto type definition"
	)

	map("textDocument/declaration", "n", "gD", vim.lsp.buf.declaration, "Goto declaration")

	map("textDocument/hover", "n", "K", vim.lsp.buf.hover, "Hover")

	map("textDocument/signatureHelp", "n", "gK", vim.lsp.buf.signature_help, "Signature help")

	map("textDocument/codeAction", { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

	map("textDocument/codeAction", "n", "<leader>cA", function()
		vim.lsp.buf.code_action({
			context = {
				only = { "source" },
				diagnostics = {},
			},
		})
	end, "Source action")

	map("textDocument/codeAction", "n", "<leader>co", function()
		vim.lsp.buf.code_action({
			apply = true,
			context = {
				only = { "source.organizeImports" },
				diagnostics = {},
			},
		})
	end, "Organize imports")

	map("textDocument/rename", "n", "<leader>cr", function()
		require("lze").trigger_load("inc-rename.nvim")
		return ":IncRename " .. vim.fn.expand("<cword>")
	end, "Rename", { expr = true })

	if
		client.name ~= "rust-analyzer"
		and (
			supports(client, "workspace/willRenameFiles", buffer)
			or supports(client, "workspace/didRenameFiles", buffer)
		)
	then
		map(nil, "n", "<leader>cR", function()
			Snacks.rename.rename_file()
		end, "Rename file")
	end

	if client.name == "clangd" then
		map(nil, "n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch source/header")
	end

	map("textDocument/documentSymbol", "n", "<leader>ss", fzf_picker("lsp_document_symbols"), "Document symbols")

	map("workspace/symbol", "n", "<leader>sS", fzf_picker("lsp_live_workspace_symbols"), "Workspace symbols")

	if supports(client, "textDocument/documentHighlight", buffer) then
		map(nil, "n", "]]", function()
			Snacks.words.jump(vim.v.count1)
		end, "Next reference")

		map(nil, "n", "[[", function()
			Snacks.words.jump(-vim.v.count1)
		end, "Previous reference")

		map(nil, "n", "<A-n>", function()
			Snacks.words.jump(vim.v.count1, true)
		end, "Next reference")

		map(nil, "n", "<A-p>", function()
			Snacks.words.jump(-vim.v.count1, true)
		end, "Previous reference")
	end
end

return {
	{
		"lazydev.nvim",
		lazy = false,
		after = function()
			require("lazydev").setup({
				library = {
					{
						path = "${3rd}/luv/library",
						words = { "vim%.uv" },
					},
					{
						path = "snacks.nvim",
						words = { "Snacks" },
					},
					{
						path = "nvim-lspconfig",
						words = { "vim%.lsp%.config" },
					},
					{
						path = "lze",
						words = { "lze" },
					},
					{
						path = "lzextras",
						words = { "lzextras" },
					},
				},
				integrations = {
					cmp = false,
				},
			})
		end,
	},

	{
		"inc-rename.nvim",
		cmd = "IncRename",
		after = function()
			require("inc_rename").setup()
		end,
	},

	{
		"nvim-lspconfig",
		lazy = false,
		after = function()
			-- Load cmp-nvim-lsp before enabling clients so every client receives
			-- completion and snippet capabilities from its initial handshake.
			require("lze").trigger_load("cmp-nvim-lsp")

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			capabilities = vim.tbl_deep_extend("force", capabilities, {
				workspace = {
					fileOperations = {
						didRename = true,
						willRename = true,
					},
				},
			})

			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						codeLens = {
							enable = true,
						},
						completion = {
							callSnippet = "Replace",
						},
						doc = {
							privateName = { "^_" },
						},
						hint = {
							enable = true,
							setType = false,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
					},
				},
			})

			local language_servers = require("config.languages").setup()

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("config_lsp_attach", {
					clear = true,
				}),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client then
						set_lsp_keymaps(client, event.buf)
					end
				end,
			})

			-- Your old configuration explicitly disabled automatic inlay hints.
			-- The toggle keeps them available when wanted.
			Snacks.toggle.inlay_hints():map("<leader>uh")

			table.insert(language_servers, "lua_ls")
			vim.lsp.enable(language_servers)
		end,
	},
}

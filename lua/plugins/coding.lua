local with_after = require("lzextras").loaders.with_after

return {
	{
		"friendly-snippets",
		dep_of = "luasnip",
	},

	{
		"cmp-nvim-lsp",
		dep_of = "nvim-cmp",
		load = with_after,
	},

	{
		"luasnip",
		dep_of = "nvim-cmp",
		keys = {
			{
				"<C-k>",
				function()
					local luasnip = require("luasnip")

					if luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					end
				end,
				mode = { "i", "s" },
				silent = true,
				desc = "Expand or jump snippet",
			},
			{
				"<C-j>",
				function()
					local luasnip = require("luasnip")

					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					end
				end,
				mode = { "i", "s" },
				silent = true,
				desc = "Jump to previous snippet",
			},
			{
				"<S-Tab>",
				function()
					local luasnip = require("luasnip")

					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					end
				end,
				mode = { "i", "s" },
				silent = true,
				desc = "Jump to previous snippet",
			},
		},
		after = function()
			local luasnip = require("luasnip")

			luasnip.setup({
				history = true,
				delete_check_events = "TextChanged",
			})

			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- These are loaded explicitly after nvim-cmp itself. Their registration
	-- scripts require cmp and therefore cannot be ordinary dependencies.
	{
		"cmp-buffer",
		lazy = true,
		load = with_after,
	},
	{
		"cmp-path",
		lazy = true,
		load = with_after,
	},
	{
		"cmp_luasnip",
		lazy = true,
		load = with_after,
	},

	{
		"nvim-cmp",
		event = "InsertEnter",
		after = function()
			require("lze").trigger_load({
				"cmp-buffer",
				"cmp-path",
				"cmp_luasnip",
			})

			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local defaults = require("cmp.config.default")()
			require("lazydev.integrations.cmp").setup()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				preselect = cmp.PreselectMode.Item,
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Down>"] = cmp.config.disable,
					["<Up>"] = cmp.config.disable,
					["<CR>"] = cmp.config.disable,
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-n>"] = cmp.mapping.select_next_item({
						behavior = cmp.SelectBehavior.Select,
					}),
					["<C-p>"] = cmp.mapping.select_prev_item({
						behavior = cmp.SelectBehavior.Select,
					}),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-y>"] = cmp.mapping.confirm({
						select = true,
					}),
					["<S-CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<C-CR>"] = cmp.mapping(function(fallback)
						cmp.abort()
						fallback()
					end, { "i", "s" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "lazydev" },
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
				formatting = {
					format = function(_, item)
						local icon = MiniIcons.get("lsp", item.kind)

						if icon then
							item.kind = icon .. " " .. item.kind
						end

						local widths = {
							abbr = 40,
							menu = 30,
						}

						for field, width in pairs(widths) do
							if item[field] and vim.fn.strdisplaywidth(item[field]) > width then
								item[field] = vim.fn.strcharpart(item[field], 0, width - 1) .. "…"
							end
						end

						return item
					end,
				},
				experimental = {
					ghost_text = false,
				},
				sorting = defaults.sorting,
			})
		end,
	},

	{
		"mini.hipatterns",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			local hipatterns = require("mini.hipatterns")

			hipatterns.setup({
				highlighters = {
					hex_color = hipatterns.gen_highlighter.hex_color({
						priority = 2000,
					}),
					shorthand = {
						pattern = "()#%x%x%x()%f[^%x%w]",
						group = function(_, _, data)
							local match = data.full_match

							if match == "#add" then
								return
							end

							local red = match:sub(2, 2)
							local green = match:sub(3, 3)
							local blue = match:sub(4, 4)
							local color = "#" .. red .. red .. green .. green .. blue .. blue

							return hipatterns.compute_hex_color_group(color, "bg")
						end,
						extmark_opts = {
							priority = 2000,
						},
					},
				},
			})

			hipatterns.enable(0)
		end,
	},

	{
		"nvim-autopairs",
		event = "InsertEnter",
		after = function()
			require("nvim-autopairs").setup()
		end,
	},

	{
		"nvim-ts-context-commentstring",
		dep_of = "mini.comment",
		after = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})
		end,
	},

	{
		"mini.comment",
		event = "DeferredUIEnter",
		after = function()
			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						return require("ts_context_commentstring.internal").calculate_commentstring()
							or vim.bo.commentstring
					end,
				},
			})
		end,
	},

	{
		"mini.surround",
		event = "DeferredUIEnter",
		after = function()
			require("mini.surround").setup({
				mappings = {
					add = "gsa",
					delete = "gsd",
					find = "gsf",
					find_left = "gsF",
					highlight = "gsh",
					replace = "gsr",
					update_n_lines = "gsn",
				},
			})
		end,
	},

	{
		"yanky.nvim",
		event = "DeferredUIEnter",
		keys = {
			{
				"<leader>p",
				"<cmd>YankyRingHistory<cr>",
				mode = { "n", "x" },
				desc = "Open yank history",
			},
			{
				"y",
				"<Plug>(YankyYank)",
				mode = { "n", "x" },
				desc = "Yank text",
			},
			{
				"p",
				"<Plug>(YankyPutAfter)",
				mode = { "n", "x" },
				desc = "Put text after cursor",
			},
			{
				"P",
				"<Plug>(YankyPutBefore)",
				mode = { "n", "x" },
				desc = "Put text before cursor",
			},
			{
				"gp",
				"<Plug>(YankyGPutAfter)",
				mode = { "n", "x" },
				desc = "Put text after selection",
			},
			{
				"gP",
				"<Plug>(YankyGPutBefore)",
				mode = { "n", "x" },
				desc = "Put text before selection",
			},
			{ "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
			{ "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
			{ "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor" },
			{ "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor" },
			{ "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor" },
			{ "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor" },
			{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
			{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
			{ ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
			{ "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
			{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
			{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
		},
		after = function()
			require("yanky").setup({
				system_clipboard = {
					sync_with_ring = false,
				},
				highlight = {
					timer = 150,
				},
			})
		end,
	},
}

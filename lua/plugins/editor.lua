local root = require("config.root")

local function config_directory()
	if vim.g.nix_info_plugin_name then
		local ok, info = pcall(require, vim.g.nix_info_plugin_name)

		if ok then
			return info.settings.config_directory
		end
	end

	return vim.fn.stdpath("config")
end

local function fzf_picker(name, opts)
	return function()
		require("fzf-lua")[name](opts or {})
	end
end

local function root_picker(name, opts)
	return function()
		require("fzf-lua")[name](vim.tbl_deep_extend("force", {
			cwd = root(),
		}, opts or {}))
	end
end

local harpoon_keys = {
	{
		"<leader>H",
		function()
			require("harpoon"):list():add()
		end,
		desc = "Harpoon file",
	},
	{
		"<leader>h",
		function()
			local harpoon = require("harpoon")
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end,
		desc = "Harpoon quick menu",
	},
}

for index = 1, 9 do
	local target = index

	harpoon_keys[#harpoon_keys + 1] = {
		"<leader>" .. target,
		function()
			require("harpoon"):list():select(target)
		end,
		desc = "Harpoon to file " .. target,
	}
end

-- Open neo-tree automatically when Neovim is started with a directory.
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("config_open_directory", { clear = true }),
	once = true,
	callback = function()
		local path = vim.fn.argv(0)
		local stat = path ~= "" and vim.uv.fs_stat(path) or nil

		if stat and stat.type == "directory" then
			require("lze").trigger_load("neo-tree.nvim")

			vim.schedule(function()
				require("neo-tree.command").execute({
					dir = vim.fs.normalize(path),
				})
			end)
		end
	end,
})

return {
	{
		"grug-far.nvim",
		cmd = { "GrugFar", "GrugFarWithin" },
		keys = {
			{
				"<leader>sr",
				function()
					local extension = vim.bo.buftype == "" and vim.fn.expand("%:e")

					require("grug-far").open({
						transient = true,
						prefills = {
							filesFilter = extension ~= "" and "*." .. extension or nil,
						},
					})
				end,
				mode = { "n", "x" },
				desc = "Search and replace",
			},
		},
		after = function()
			require("grug-far").setup({})
		end,
	},

	{
		"flash.nvim",
		event = "DeferredUIEnter",
		keys = {
			{
				"s",
				function()
					require("flash").jump()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash",
			},
			{
				"S",
				function()
					require("flash").treesitter()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash Treesitter",
			},
			{
				"r",
				function()
					require("flash").remote()
				end,
				mode = "o",
				desc = "Remote Flash",
			},
			{
				"R",
				function()
					require("flash").treesitter_search()
				end,
				mode = { "o", "x" },
				desc = "Treesitter search",
			},
			{
				"<C-s>",
				function()
					require("flash").toggle()
				end,
				mode = "c",
				desc = "Toggle Flash search",
			},
			{
				"<C-Space>",
				function()
					require("flash").treesitter({
						actions = {
							["<C-Space>"] = "next",
							["<BS>"] = "prev",
						},
					})
				end,
				mode = { "n", "x", "o" },
				desc = "Treesitter incremental selection",
			},
		},
		after = function()
			require("flash").setup({})
		end,
	},

	{
		"fzf-lua",
		cmd = "FzfLua",
		on_require = "fzf-lua",
		beforeAll = function()
			local fallback = vim.ui.select
			local select

			select = function(...)
				require("lze").trigger_load("fzf-lua")

				if vim.ui.select == select then
					return fallback(...)
				end

				return vim.ui.select(...)
			end

			vim.ui.select = select
		end,
		keys = {
			{
				"<leader>,",
				"<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
				desc = "Switch buffer",
			},
			{
				"<leader>/",
				root_picker("live_grep"),
				desc = "Grep (root)",
			},
			{
				"<leader>:",
				"<cmd>FzfLua command_history<cr>",
				desc = "Command history",
			},
			{
				"<leader><space>",
				root_picker("files"),
				desc = "Find files (root)",
			},

			-- Files
			{
				"<leader>fb",
				"<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
				desc = "Buffers",
			},
			{
				"<leader>fB",
				"<cmd>FzfLua buffers<cr>",
				desc = "All buffers",
			},
			{
				"<leader>fc",
				function()
					require("fzf-lua").files({
						cwd = config_directory(),
					})
				end,
				desc = "Configuration files",
			},
			{
				"<leader>ff",
				root_picker("files"),
				desc = "Find files (root)",
			},
			{
				"<leader>fF",
				fzf_picker("files"),
				desc = "Find files (cwd)",
			},
			{
				"<leader>fg",
				"<cmd>FzfLua git_files<cr>",
				desc = "Git files",
			},
			{
				"<leader>fr",
				"<cmd>FzfLua oldfiles<cr>",
				desc = "Recent files",
			},
			{
				"<leader>fR",
				function()
					require("fzf-lua").oldfiles({
						cwd = vim.uv.cwd(),
					})
				end,
				desc = "Recent files (cwd)",
			},

			-- Git
			{
				"<leader>gc",
				"<cmd>FzfLua git_commits<cr>",
				desc = "Git commits",
			},
			{
				"<leader>gd",
				"<cmd>FzfLua git_diff<cr>",
				desc = "Git diff",
			},
			{
				"<leader>gl",
				root_picker("git_commits"),
				desc = "Git log",
			},
			{
				"<leader>gL",
				function()
					require("fzf-lua").git_commits({
						cwd = vim.uv.cwd(),
					})
				end,
				desc = "Git log (cwd)",
			},
			{
				"<leader>gb",
				"<cmd>FzfLua git_blame<cr>",
				desc = "Git blame",
			},
			{
				"<leader>gf",
				"<cmd>FzfLua git_bcommits<cr>",
				desc = "Current file history",
			},
			{
				"<leader>gs",
				"<cmd>FzfLua git_status<cr>",
				desc = "Git status",
			},
			{
				"<leader>gS",
				"<cmd>FzfLua git_stash<cr>",
				desc = "Git stash",
			},

			-- Search
			{
				'<leader>s"',
				"<cmd>FzfLua registers<cr>",
				desc = "Registers",
			},
			{
				"<leader>s/",
				"<cmd>FzfLua search_history<cr>",
				desc = "Search history",
			},
			{
				"<leader>sa",
				"<cmd>FzfLua autocmds<cr>",
				desc = "Autocmds",
			},
			{
				"<leader>sb",
				"<cmd>FzfLua lines<cr>",
				desc = "Buffer lines",
			},
			{
				"<leader>sB",
				"<cmd>FzfLua blines<cr>",
				desc = "Current buffer lines",
			},
			{
				"<leader>sc",
				"<cmd>FzfLua command_history<cr>",
				desc = "Command history",
			},
			{
				"<leader>sC",
				"<cmd>FzfLua commands<cr>",
				desc = "Commands",
			},
			{
				"<leader>sd",
				"<cmd>FzfLua diagnostics_document<cr>",
				desc = "Buffer diagnostics",
			},
			{
				"<leader>sD",
				"<cmd>FzfLua diagnostics_workspace<cr>",
				desc = "Workspace diagnostics",
			},
			{
				"<leader>sg",
				root_picker("live_grep"),
				desc = "Grep (root)",
			},
			{
				"<leader>sG",
				fzf_picker("live_grep"),
				desc = "Grep (cwd)",
			},
			{
				"<leader>sh",
				"<cmd>FzfLua helptags<cr>",
				desc = "Help pages",
			},
			{
				"<leader>sH",
				"<cmd>FzfLua highlights<cr>",
				desc = "Highlights",
			},
			{
				"<leader>sj",
				"<cmd>FzfLua jumps<cr>",
				desc = "Jumps",
			},
			{
				"<leader>sk",
				"<cmd>FzfLua keymaps<cr>",
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				"<cmd>FzfLua loclist<cr>",
				desc = "Location list",
			},
			{
				"<leader>sM",
				"<cmd>FzfLua manpages<cr>",
				desc = "Man pages",
			},
			{
				"<leader>sm",
				"<cmd>FzfLua marks<cr>",
				desc = "Marks",
			},
			{
				"<leader>sq",
				"<cmd>FzfLua quickfix<cr>",
				desc = "Quickfix list",
			},
			{
				"<leader>sR",
				"<cmd>FzfLua resume<cr>",
				desc = "Resume search",
			},
			{
				"<leader>ss",
				"<cmd>FzfLua spell_suggest<cr>",
				desc = "Spelling suggestions",
			},
			{
				"<leader>sw",
				root_picker("grep_cword"),
				desc = "Word (root)",
				mode = "n",
			},
			{
				"<leader>sw",
				root_picker("grep_visual"),
				desc = "Selection (root)",
				mode = "x",
			},
			{
				"<leader>sW",
				fzf_picker("grep_cword"),
				desc = "Word (cwd)",
				mode = "n",
			},
			{
				"<leader>sW",
				fzf_picker("grep_visual"),
				desc = "Selection (cwd)",
				mode = "x",
			},
		},
		after = function()
			local fzf = require("fzf-lua")
			local actions = require("fzf-lua.actions")

			require("lze").trigger_load("trouble.nvim")
			local trouble_action = require("trouble.sources.fzf").actions.open

			fzf.setup({
				"default-title",
				fzf_colors = true,
				fzf_opts = {
					["--no-scrollbar"] = true,
				},
				defaults = {
					formatter = "path.dirname_first",
				},
				actions = {
					files = {
						true,
						["ctrl-t"] = trouble_action,
					},
				},
				winopts = {
					width = 0.8,
					height = 0.8,
					row = 0.5,
					col = 0.5,
					preview = {
						scrollchars = { "┃", "" },
					},
				},
				files = {
					cwd_prompt = false,
					actions = {
						["alt-i"] = actions.toggle_ignore,
						["alt-h"] = actions.toggle_hidden,
					},
				},
				grep = {
					actions = {
						["alt-i"] = actions.toggle_ignore,
						["alt-h"] = actions.toggle_hidden,
					},
				},
				keymap = {
					fzf = {
						["ctrl-q"] = "select-all+accept",
						["ctrl-u"] = "half-page-up",
						["ctrl-d"] = "half-page-down",
						["ctrl-x"] = "jump",
						["ctrl-f"] = "preview-page-down",
						["ctrl-b"] = "preview-page-up",
					},
					builtin = {
						["<C-f>"] = "preview-page-down",
						["<C-b>"] = "preview-page-up",
					},
				},
			})

			fzf.register_ui_select(function(options)
				return vim.tbl_deep_extend("force", options, {
					prompt = " ",
					winopts = {
						width = 0.5,
						height = 0.5,
						title_pos = "center",
					},
				})
			end)
		end,
	},

	{
		"harpoon2",
		which_key = "harpoon",
		keys = harpoon_keys,
		after = function()
			require("harpoon"):setup({
				settings = {
					save_on_toggle = true,
				},
			})
		end,
	},

	{
		"mini.diff",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"<leader>go",
				function()
					require("mini.diff").toggle_overlay(0)
				end,
				desc = "Toggle mini.diff overlay",
			},
		},
		after = function()
			require("mini.diff").setup({
				view = {
					style = "sign",
					signs = {
						add = "▎",
						change = "▎",
						delete = "",
					},
				},
			})

			Snacks.toggle({
				name = "Mini Diff Signs",
				get = function()
					return vim.g.minidiff_disable ~= true
				end,
				set = function(enabled)
					vim.g.minidiff_disable = not enabled

					if enabled then
						require("mini.diff").enable(0)
					else
						require("mini.diff").disable(0)
					end

					vim.defer_fn(function()
						vim.cmd.redraw({ bang = true })
					end, 200)
				end,
			}):map("<leader>uG")
		end,
	},

	{
		"trouble.nvim",
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer diagnostics",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle<cr>",
				desc = "Document symbols",
			},
			{
				"<leader>cS",
				"<cmd>Trouble lsp toggle<cr>",
				desc = "LSP definitions and references",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location list",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list",
			},
		},
		after = function()
			require("trouble").setup({
				modes = {
					lsp = {
						win = {
							position = "right",
						},
					},
				},
			})
		end,
	},

	{
		"todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		cmd = {
			"TodoQuickFix",
			"TodoLocList",
			"TodoFzfLua",
			"TodoTrouble",
		},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{
				"<leader>xt",
				"<cmd>Trouble todo toggle<cr>",
				desc = "Todo comments",
			},
			{
				"<leader>xT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
				desc = "Todo/Fix/Fixme comments",
			},
			{
				"<leader>st",
				"<cmd>TodoFzfLua<cr>",
				desc = "Todo comments",
			},
			{
				"<leader>sT",
				"<cmd>TodoFzfLua keywords=TODO,FIX,FIXME<cr>",
				desc = "Todo/Fix/Fixme comments",
			},
		},
		after = function()
			require("todo-comments").setup({})
		end,
	},

	{
		"nui.nvim",
		dep_of = { "neo-tree.nvim" },
	},

	{
		"plenary.nvim",
		dep_of = { "neo-tree.nvim", "harpoon2", "todo-comments.nvim" },
	},

	{
		"neo-tree.nvim",
		cmd = "Neotree",
		keys = {
			{
				"<leader>fe",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						dir = root(),
					})
				end,
				desc = "Explorer (root)",
			},
			{
				"<leader>fE",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						dir = vim.uv.cwd(),
					})
				end,
				desc = "Explorer (cwd)",
			},
			{
				"<leader>e",
				"<leader>fe",
				remap = true,
				desc = "Explorer (root)",
			},
			{
				"<leader>E",
				"<leader>fE",
				remap = true,
				desc = "Explorer (cwd)",
			},
			{
				"<leader>ge",
				function()
					require("neo-tree.command").execute({
						source = "git_status",
						toggle = true,
					})
				end,
				desc = "Git explorer",
			},
			{
				"<leader>be",
				function()
					require("neo-tree.command").execute({
						source = "buffers",
						toggle = true,
					})
				end,
				desc = "Buffer explorer",
			},
		},
		after = function()
			local events = require("neo-tree.events")

			require("neo-tree").setup({
				sources = {
					"filesystem",
					"buffers",
					"git_status",
				},
				open_files_do_not_replace_types = {
					"terminal",
					"Trouble",
					"trouble",
					"qf",
				},
				filesystem = {
					bind_to_cwd = false,
					follow_current_file = {
						enabled = true,
					},
					use_libuv_file_watcher = true,
				},
				window = {
					mappings = {
						["l"] = "open",
						["h"] = "close_node",
						["<Space>"] = "none",
						["Y"] = {
							function(state)
								vim.fn.setreg("+", state.tree:get_node():get_id(), "c")
							end,
							desc = "Copy path",
						},
						["O"] = {
							function(state)
								vim.ui.open(state.tree:get_node().path)
							end,
							desc = "Open with system application",
						},
						["P"] = {
							"toggle_preview",
							config = {
								use_float = false,
							},
						},
					},
				},
				default_component_configs = {
					indent = {
						with_expanders = true,
						expander_collapsed = "",
						expander_expanded = "",
						expander_highlight = "NeoTreeExpander",
					},
					git_status = {
						symbols = {
							unstaged = "󰄱",
							staged = "󰱒",
						},
					},
				},
				event_handlers = {
					{
						event = events.FILE_MOVED,
						handler = function(data)
							Snacks.rename.on_rename_file(data.source, data.destination)
						end,
					},
					{
						event = events.FILE_RENAMED,
						handler = function(data)
							Snacks.rename.on_rename_file(data.source, data.destination)
						end,
					},
				},
			})

			vim.api.nvim_create_autocmd("TermClose", {
				pattern = "*lazygit",
				callback = function()
					if package.loaded["neo-tree.sources.git_status"] then
						require("neo-tree.sources.git_status").refresh()
					end
				end,
			})
		end,
	},
}

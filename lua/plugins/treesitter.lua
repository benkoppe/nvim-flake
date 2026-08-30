local function has_query(language, query)
	local ok, parsed = pcall(vim.treesitter.query.get, language, query)
	return ok and parsed ~= nil
end

local function ai_buffer(ai_type)
	local start_line = 1
	local end_line = vim.fn.line("$")

	if ai_type == "i" then
		local first_nonblank = vim.fn.nextnonblank(start_line)
		local last_nonblank = vim.fn.prevnonblank(end_line)

		if first_nonblank == 0 or last_nonblank == 0 then
			return {
				from = {
					line = start_line,
					col = 1,
				},
			}
		end

		start_line = first_nonblank
		end_line = last_nonblank
	end

	return {
		from = {
			line = start_line,
			col = 1,
		},
		to = {
			line = end_line,
			col = math.max(vim.fn.getline(end_line):len(), 1),
		},
	}
end

return {
	{
		"nvim-treesitter",
		lazy = false,
		after = function()
			local treesitter = require("nvim-treesitter")

			treesitter.setup({})

			local function attach(buffer)
				local filetype = vim.bo[buffer].filetype
				local language = vim.treesitter.language.get_lang(filetype)

				if not language or not vim.treesitter.language.add(language) then
					return
				end

				if language ~= "latex" and has_query(language, "highlights") then
					pcall(vim.treesitter.start, buffer, language)
				end

				if has_query(language, "indents") then
					vim.bo[buffer].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end

				if has_query(language, "folds") then
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("config_treesitter", {
					clear = true,
				}),
				callback = function(event)
					attach(event.buf)
				end,
			})

			for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].filetype ~= "" then
					attach(buffer)
				end
			end
		end,
	},

	{
		"nvim-treesitter-textobjects",
		lazy = false,
		after = function()
			require("nvim-treesitter-textobjects").setup({
				move = {
					set_jumps = true,
				},
			})

			local movements = {
				{
					key = "]f",
					method = "goto_next_start",
					query = "@function.outer",
					desc = "Next function start",
				},
				{
					key = "]F",
					method = "goto_next_end",
					query = "@function.outer",
					desc = "Next function end",
				},
				{
					key = "[f",
					method = "goto_previous_start",
					query = "@function.outer",
					desc = "Previous function start",
				},
				{
					key = "[F",
					method = "goto_previous_end",
					query = "@function.outer",
					desc = "Previous function end",
				},
				{
					key = "]c",
					method = "goto_next_start",
					query = "@class.outer",
					desc = "Next class start",
				},
				{
					key = "]C",
					method = "goto_next_end",
					query = "@class.outer",
					desc = "Next class end",
				},
				{
					key = "[c",
					method = "goto_previous_start",
					query = "@class.outer",
					desc = "Previous class start",
				},
				{
					key = "[C",
					method = "goto_previous_end",
					query = "@class.outer",
					desc = "Previous class end",
				},
				{
					key = "]a",
					method = "goto_next_start",
					query = "@parameter.inner",
					desc = "Next parameter start",
				},
				{
					key = "]A",
					method = "goto_next_end",
					query = "@parameter.inner",
					desc = "Next parameter end",
				},
				{
					key = "[a",
					method = "goto_previous_start",
					query = "@parameter.inner",
					desc = "Previous parameter start",
				},
				{
					key = "[A",
					method = "goto_previous_end",
					query = "@parameter.inner",
					desc = "Previous parameter end",
				},
			}

			local function attach(buffer)
				local language = vim.treesitter.language.get_lang(vim.bo[buffer].filetype)

				if not language or not has_query(language, "textobjects") then
					return
				end

				for _, movement in ipairs(movements) do
					vim.keymap.set({ "n", "x", "o" }, movement.key, function()
						if vim.wo.diff and movement.key:find("[cC]") then
							vim.cmd("normal! " .. movement.key)
							return
						end

						require("nvim-treesitter-textobjects.move")[movement.method](movement.query, "textobjects")
					end, {
						buffer = buffer,
						silent = true,
						desc = movement.desc,
					})
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("config_treesitter_textobjects", {
					clear = true,
				}),
				callback = function(event)
					attach(event.buf)
				end,
			})

			for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].filetype ~= "" then
					attach(buffer)
				end
			end
		end,
	},

	{
		"mini.ai",
		lazy = false,
		after = function()
			local ai = require("mini.ai")

			ai.setup({
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = {
							"@block.outer",
							"@conditional.outer",
							"@loop.outer",
						},
						i = {
							"@block.inner",
							"@conditional.inner",
							"@loop.inner",
						},
					}),
					f = ai.gen_spec.treesitter({
						a = "@function.outer",
						i = "@function.inner",
					}),
					c = ai.gen_spec.treesitter({
						a = "@class.outer",
						i = "@class.inner",
					}),
					t = {
						"<([%p%w]-)%f[^<%w][^<>]->.-</%1>",
						"^<.->().*()</[^/]->$",
					},
					d = {
						"%f[%d]%d+",
					},
					e = {
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					g = ai_buffer,
					u = ai.gen_spec.function_call(),
					U = ai.gen_spec.function_call({
						name_pattern = "[%w_]",
					}),
				},
			})
		end,
	},

	{
		"nvim-treesitter-context",
		lazy = false,
		after = function()
			local context = require("treesitter-context")

			context.setup({
				mode = "cursor",
				max_lines = 3,
			})

			Snacks.toggle({
				name = "Treesitter context",
				get = context.enabled,
				set = function(enabled)
					if enabled then
						context.enable()
					else
						context.disable()
					end
				end,
			}):map("<leader>ut")
		end,
	},

	{
		"nvim-ts-autotag",
		lazy = false,
		after = function()
			require("nvim-ts-autotag").setup()
		end,
	},
}

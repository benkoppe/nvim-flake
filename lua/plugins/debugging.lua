local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
	local args_string = type(args) == "table" and table.concat(args, " ") or args

	config = vim.deepcopy(config)
	config.args = function()
		local input = vim.fn.input("Run with args: ", args_string)
		return require("dap.utils").splitstr(vim.fn.expand(input))
	end

	return config
end

local keys = {
	{
		"<leader>dB",
		function()
			require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end,
		desc = "Breakpoint condition",
	},
	{
		"<leader>db",
		function()
			require("dap").toggle_breakpoint()
		end,
		desc = "Toggle breakpoint",
	},
	{
		"<leader>dc",
		function()
			require("dap").continue()
		end,
		desc = "Run or continue",
	},
	{
		"<leader>da",
		function()
			require("dap").continue({ before = get_args })
		end,
		desc = "Run with arguments",
	},
	{
		"<leader>dC",
		function()
			require("dap").run_to_cursor()
		end,
		desc = "Run to cursor",
	},
	{
		"<leader>dg",
		function()
			require("dap").goto_()
		end,
		desc = "Go to line without executing",
	},
	{
		"<leader>di",
		function()
			require("dap").step_into()
		end,
		desc = "Step into",
	},
	{
		"<leader>dj",
		function()
			require("dap").down()
		end,
		desc = "Down stack frame",
	},
	{
		"<leader>dk",
		function()
			require("dap").up()
		end,
		desc = "Up stack frame",
	},
	{
		"<leader>dl",
		function()
			require("dap").run_last()
		end,
		desc = "Run last",
	},
	{
		"<leader>do",
		function()
			require("dap").step_out()
		end,
		desc = "Step out",
	},
	{
		"<leader>dO",
		function()
			require("dap").step_over()
		end,
		desc = "Step over",
	},
	{
		"<leader>dP",
		function()
			require("dap").pause()
		end,
		desc = "Pause",
	},
	{
		"<leader>dr",
		function()
			require("dap").repl.toggle()
		end,
		desc = "Toggle REPL",
	},
	{
		"<leader>ds",
		function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end,
		desc = "Scopes",
	},
	{
		"<leader>dt",
		function()
			require("dap").terminate()
		end,
		desc = "Terminate",
	},
	{
		"<leader>dw",
		function()
			require("dap.ui.widgets").hover()
		end,
		desc = "Widgets",
	},
	{
		"<leader>du",
		function()
			require("dapui").toggle({})
		end,
		desc = "DAP UI",
	},
	{
		"<leader>de",
		function()
			require("dapui").eval()
		end,
		mode = { "n", "x" },
		desc = "Evaluate expression",
	},
	{
		"<leader>dgt",
		function()
			require("dap-go").debug_test()
		end,
		desc = "Debug Go test",
	},
	{
		"<leader>dgl",
		function()
			require("dap-go").debug_last_test()
		end,
		desc = "Debug last Go test",
	},
	{
		"<leader>dPt",
		function()
			require("dap-python").test_method()
		end,
		desc = "Debug Python test method",
	},
	{
		"<leader>dPc",
		function()
			require("dap-python").test_class()
		end,
		desc = "Debug Python test class",
	},
}

return {
	{
		"nvim-nio",
		dep_of = "nvim-dap-ui",
	},

	{
		"nvim-dap-ui",
		dep_of = "nvim-dap",
	},

	{
		"nvim-dap-virtual-text",
		dep_of = "nvim-dap",
	},

	{
		"nvim-dap-go",
		dep_of = "nvim-dap",
	},

	{
		"nvim-dap-python",
		dep_of = "nvim-dap",
	},

	{
		"nvim-dap",
		on_require = "dap",
		cmd = {
			"DapNew",
			"DapContinue",
			"DapToggleBreakpoint",
			"DapClearBreakpoints",
			"DapToggleRepl",
			"DapStepOver",
			"DapStepInto",
			"DapStepOut",
			"DapPause",
			"DapTerminate",
			"DapDisconnect",
			"DapRestartFrame",
			"DapEval",
			"DapSetLogLevel",
			"DapShowLog",
		},
		keys = keys,
		after = function()
			local dap = require("dap")
			local dapui = require("dapui")

			vim.api.nvim_set_hl(0, "DapStoppedLine", {
				default = true,
				link = "Visual",
			})

			local signs = {
				DapBreakpoint = {
					text = "",
					texthl = "DiagnosticError",
				},
				DapBreakpointCondition = {
					text = "",
					texthl = "DiagnosticWarn",
				},
				DapBreakpointRejected = {
					text = "",
					texthl = "DiagnosticError",
				},
				DapLogPoint = {
					text = ".>",
					texthl = "DiagnosticInfo",
				},
				DapStopped = {
					text = "󰁕",
					texthl = "DiagnosticWarn",
					linehl = "DapStoppedLine",
					numhl = "DapStoppedLine",
				},
			}

			for name, sign in pairs(signs) do
				vim.fn.sign_define(name, sign)
			end

			dapui.setup({})
			require("nvim-dap-virtual-text").setup({})

			dap.listeners.after.event_initialized.dapui = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated.dapui = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited.dapui = function()
				dapui.close({})
			end

			-- Rustaceanvim detects codelldb from PATH itself. This adapter is
			-- also shared by C and C++.
			dap.adapters.codelldb = {
				type = "server",
				host = "127.0.0.1",
				port = "${port}",
				executable = {
					command = "codelldb",
					args = { "--port", "${port}" },
				},
			}

			local native_configurations = {
				{
					type = "codelldb",
					request = "launch",
					name = "Launch executable",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					type = "codelldb",
					request = "attach",
					name = "Attach to process",
					pid = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}

			dap.configurations.c = vim.deepcopy(native_configurations)
			dap.configurations.cpp = vim.deepcopy(native_configurations)

			dap.configurations.zig = vim.deepcopy(native_configurations)

			local nix_info = require(vim.g.nix_info_plugin_name)

			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = {
					nix_info.settings.php_debug_adapter,
				},
			}

			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Listen for Xdebug",
					port = 9003,
				},
			}

			dap.adapters.netcoredbg = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
				options = {
					detached = false,
				},
			}

			local dotnet_configurations = {
				{
					type = "netcoredbg",
					request = "launch",
					name = "Launch .NET assembly",
					program = function()
						return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
				},
				{
					type = "netcoredbg",
					request = "attach",
					name = "Attach to .NET process",
					processId = require("dap.utils").pick_process,
				},
			}

			dap.configurations.cs = vim.deepcopy(dotnet_configurations)
			dap.configurations.fsharp = vim.deepcopy(dotnet_configurations)
			dap.configurations.vb = vim.deepcopy(dotnet_configurations)

			require("dap-go").setup({})
			require("dap-python").setup("debugpy-adapter")

			local js_adapter = {
				type = "server",
				host = "127.0.0.1",
				port = "${port}",
				executable = {
					command = "js-debug",
					args = { "${port}", "127.0.0.1" },
				},
			}

			for _, adapter in ipairs({
				"pwa-node",
				"node",
				"node-terminal",
				"pwa-chrome",
				"pwa-msedge",
			}) do
				dap.adapters[adapter] = js_adapter
			end

			local function js_configurations(runtime)
				return {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						runtimeExecutable = runtime,
						sourceMaps = true,
						skipFiles = {
							"<node_internals>/**",
							"node_modules/**",
						},
						resolveSourceMapLocations = {
							"${workspaceFolder}/**",
							"!**/node_modules/**",
						},
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = {
							"<node_internals>/**",
							"node_modules/**",
						},
						resolveSourceMapLocations = {
							"${workspaceFolder}/**",
							"!**/node_modules/**",
						},
					},
				}
			end

			dap.configurations.javascript = js_configurations("node")
			dap.configurations.javascriptreact = js_configurations("tsx")
			dap.configurations.typescript = js_configurations("tsx")
			dap.configurations.typescriptreact = js_configurations("tsx")

			dap.adapters.ghc = {
				type = "executable",
				command = "haskell-debug-adapter",
			}

			dap.configurations.haskell = {
				{
					type = "ghc",
					request = "launch",
					name = "Launch current Haskell file",
					workspace = "${workspaceFolder}",
					startup = "${file}",
					startupFunc = "",
					startupArgs = "",
					stopOnEntry = false,
					mainArgs = "",
					ghciPrompt = "H>>= ",
					ghciInitialPrompt = "> ",
					ghciCmd = "ghci-dap",
					ghciEnv = vim.empty_dict(),
					logFile = vim.fn.stdpath("state") .. "/haskell-debug-adapter.log",
					logLevel = "WARNING",
					forceInspect = false,
				},
			}
		end,
	},
}

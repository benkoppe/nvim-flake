-- Effective root priority:
-- 1. Attached LSP root
-- 2. Nearest .git or lua ancestor
-- 3. Current working directory

local M = {}

local function normalize(path)
	return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
end

local function contains(root, path)
	root = normalize(root)
	path = normalize(path)

	return path == root or vim.startswith(path, root .. "/")
end

local function lsp_roots(buf)
	local roots = {}
	local path = normalize(vim.api.nvim_buf_get_name(buf))

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		for _, folder in ipairs(client.workspace_folders or {}) do
			local root = vim.uri_to_fname(folder.uri)

			if contains(root, path) then
				roots[#roots + 1] = normalize(root)
			end
		end

		if client.root_dir and contains(client.root_dir, path) then
			roots[#roots + 1] = normalize(client.root_dir)
		end
	end

	table.sort(roots, function(a, b)
		return #a > #b
	end)

	return roots
end

function M.get(buf)
	buf = buf or 0

	local name = vim.api.nvim_buf_get_name(buf)
	local path = name ~= "" and normalize(name) or normalize(vim.uv.cwd())

	local roots = lsp_roots(buf)
	if roots[1] then
		return roots[1]
	end

	return vim.fs.root(path, { ".git", "lua" }) or normalize(vim.uv.cwd())
end

function M.git(buf)
	local root = M.get(buf)
	return vim.fs.root(root, ".git") or root
end

return setmetatable(M, {
	__call = function(_, ...)
		return M.get(...)
	end,
})

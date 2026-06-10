-- Shared diagnostic display config: lsp.lua toggles show/hide around
-- insert mode, trouble.lua re-applies "shown" before opening its panels.
local M = {}

M.shown = {
	severity_sort = true,
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = false,
	virtual_lines = { current_line = true },
	signs = true,
	float = { border = "rounded", source = "if_many" },
}

M.hidden = {
	severity_sort = true,
	underline = false,
	virtual_text = false,
	virtual_lines = false,
	signs = false,
	float = { border = "rounded", source = "if_many" },
}

function M.show()
	vim.diagnostic.config(M.shown)
end

function M.hide()
	vim.diagnostic.config(M.hidden)
end

return M

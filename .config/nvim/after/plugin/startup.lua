local cheatsheet_path = vim.fn.stdpath("config") .. "/cheatsheet.txt"

local function read_cheatsheet()
	local lines = {}
	local f = io.open(cheatsheet_path, "r")
	if f then
		for line in f:lines() do
			table.insert(lines, line)
		end
		f:close()
	else
		lines = { "  No cheatsheet found. Create one at:", "  " .. cheatsheet_path }
	end
	return lines
end

local function show_cheatsheet_telescope()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")

	local lines = read_cheatsheet()

	pickers.new({}, {
		prompt_title = "Cheatsheet",
		finder = finders.new_table({ results = lines }),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
			end)
			return true
		end,
	}):find()
end

-- Startup screen: reuse buffer 1 instead of creating a new one.
-- Creating + wiping buffers during VimEnter races with treesitter.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() > 0 or vim.fn.line2byte(vim.fn.line("$")) ~= -1 then
			return
		end

		local buf = vim.api.nvim_get_current_buf()

		-- Disable treesitter on this buffer before adding content
		pcall(vim.treesitter.stop, buf)

		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].buflisted = false
		vim.bo[buf].swapfile = false
		vim.bo[buf].filetype = ""

		local lines = read_cheatsheet()

		local win_height = vim.api.nvim_win_get_height(0)
		local pad = math.max(0, math.floor((win_height - #lines) / 2))
		local padded = {}
		for _ = 1, pad do
			table.insert(padded, "")
		end
		for _, l in ipairs(lines) do
			table.insert(padded, l)
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)
		vim.bo[buf].modifiable = false
		-- bufhidden=wipe handles cleanup automatically when a real file opens
	end,
})

vim.keymap.set("n", "<leader>ch", show_cheatsheet_telescope, { desc = "Show cheatsheet" })

vim.api.nvim_create_user_command("Cheatsheet", function()
	vim.cmd("edit " .. cheatsheet_path)
end, { desc = "Open cheatsheet for editing" })

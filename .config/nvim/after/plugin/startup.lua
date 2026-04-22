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

-- Startup: show cheatsheet in a full-screen float over the untouched buf 1.
-- This avoids treesitter conflicts — buf 1 is never modified.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() > 0 or vim.fn.line2byte(vim.fn.line("$")) ~= -1 then
			return
		end

		local lines = read_cheatsheet()

		local buf = vim.api.nvim_create_buf(false, true)

		local win_width = vim.o.columns
		local win_height = vim.o.lines - 2

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

		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			row = 0,
			col = 0,
			width = win_width,
			height = win_height,
			style = "minimal",
			zindex = 1,
		})

		local function close()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end

		vim.keymap.set("n", "<leader>pf", function()
			close()
			require("telescope.builtin").find_files()
		end, { buffer = buf, desc = "Find files" })

		vim.keymap.set("n", "<leader>pg", function()
			close()
			require("telescope.builtin").git_files()
		end, { buffer = buf, desc = "Git files" })

		vim.keymap.set("n", "<leader>pv", function()
			close()
			vim.cmd.Ex()
		end, { buffer = buf, desc = "Open netrw" })

		for _, key in ipairs({ "q", "<Esc>", "<CR>" }) do
			vim.keymap.set("n", key, close, { buffer = buf, nowait = true })
		end
	end,
})

vim.keymap.set("n", "<leader>ch", show_cheatsheet_telescope, { desc = "Show cheatsheet" })

vim.api.nvim_create_user_command("Cheatsheet", function()
	vim.cmd("edit " .. cheatsheet_path)
end, { desc = "Open cheatsheet for editing" })

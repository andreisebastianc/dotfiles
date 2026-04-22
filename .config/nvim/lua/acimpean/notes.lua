local function get_notes_path()
	local markers = { ".git", "package.json", "Gemfile", "go.mod", "Cargo.toml", "build.zig" }
	local root = vim.fs.root(0, markers)
	if root then
		return root .. "/.nvim-notes.txt"
	end
	return vim.fn.stdpath("data") .. "/nvim-notes.txt"
end

local function ensure_file(path)
	if vim.fn.filereadable(path) == 0 then
		local f = io.open(path, "w")
		if f then f:close() end
	end
end

local function open_notes()
	local path = get_notes_path()
	ensure_file(path)

	local notes = {}
	for line in io.lines(path) do
		if line ~= "" then
			table.insert(notes, line)
		end
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	pickers.new({}, {
		prompt_title = "Notes (" .. vim.fn.fnamemodify(path, ":~:.") .. ")",
		finder = finders.new_table({ results = notes }),
		sorter = conf.generic_sorter({}),
		previewer = previewers.new_buffer_previewer({
			title = "Note",
			define_preview = function(self, entry)
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { entry.value })
				vim.wo[self.state.winid].wrap = true
				vim.wo[self.state.winid].linebreak = true
			end,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
			end)
			map("n", "dd", function()
				local selection = action_state.get_selected_entry()
				if not selection then return end
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				current_picker:delete_selection(function(sel)
					for i, note in ipairs(notes) do
						if note == sel.value then
							table.remove(notes, i)
							break
						end
					end
					local f = io.open(path, "w")
					if f then
						for _, n in ipairs(notes) do
							f:write(n .. "\n")
						end
						f:close()
					end
				end)
			end, { desc = "Delete note" })
			return true
		end,
	}):find()
end

local function add_note()
	local path = get_notes_path()
	ensure_file(path)

	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.min(100, math.floor(vim.o.columns * 0.7))

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - 15) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = 15,
		border = "rounded",
		title = " New note (<C-s> to save, Esc to cancel) ",
		title_pos = "center",
	})

	vim.wo[win].number = true

	vim.cmd("startinsert")

	local function save()
		local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		vim.cmd("stopinsert")
		local note = table.concat(content, " ")
		note = note:gsub("^%s+", ""):gsub("%s+$", "")
		if note ~= "" then
			local f = io.open(path, "a")
			if f then
				f:write(note .. "\n")
				f:close()
			end
			vim.notify("Note added", vim.log.levels.INFO)
		end
	end

	local function cancel()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		vim.cmd("stopinsert")
	end

	vim.keymap.set({ "i", "n" }, "<C-s>", save, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<Esc>", cancel, { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", cancel, { buffer = buf, nowait = true })
	vim.keymap.set("n", "q", cancel, { buffer = buf, nowait = true })
end

vim.keymap.set("n", "<leader>nn", open_notes, { desc = "Open notes" })
vim.keymap.set("n", "<leader>na", add_note, { desc = "Add a note" })

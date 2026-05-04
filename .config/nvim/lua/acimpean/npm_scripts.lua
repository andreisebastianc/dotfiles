local function find_package_jsons(root)
	return vim.fn.systemlist({
		"rg", "--files",
		"--glob", "package.json",
		"--glob", "!**/node_modules/**",
		"--glob", "!**/.git/**",
		root,
	})
end

local function read_json(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local content = f:read("*a")
	f:close()
	local ok, data = pcall(vim.json.decode, content)
	return ok and data or nil
end

local function detect_pm(root)
	if vim.uv.fs_stat(root .. "/pnpm-lock.yaml") then return "pnpm" end
	if vim.uv.fs_stat(root .. "/yarn.lock") then return "yarn" end
	if vim.uv.fs_stat(root .. "/bun.lockb") or vim.uv.fs_stat(root .. "/bun.lock") then return "bun" end
	return "npm"
end

local function collect_scripts(root)
	local entries = {}
	for _, path in ipairs(find_package_jsons(root)) do
		local data = read_json(path)
		if data and type(data.scripts) == "table" then
			local dir = vim.fn.fnamemodify(path, ":h")
			local pkg = data.name or vim.fn.fnamemodify(dir, ":t")
			for name, cmd in pairs(data.scripts) do
				table.insert(entries, { pkg = pkg, script = name, cmd = cmd, dir = dir })
			end
		end
	end
	table.sort(entries, function(a, b)
		if a.pkg == b.pkg then return a.script < b.script end
		return a.pkg < b.pkg
	end)
	return entries
end

local function run_in_tmux(dir, pm, script)
	local shell_cmd = string.format(
		'cd %s && %s run %s; ec=$?; if [ $ec -ne 0 ]; then printf "\\n[exit %%s] press enter to close" "$ec"; read _; fi',
		vim.fn.shellescape(dir), pm, vim.fn.shellescape(script)
	)
	vim.fn.system({ "tmux", "split-window", "-v", "-l", "30%", shell_cmd })
end

local function run_in_nvim(dir, pm, script)
	vim.cmd("botright 15split | enew")
	local win = vim.api.nvim_get_current_win()
	vim.fn.jobstart({ pm, "run", script }, {
		cwd = dir,
		term = true,
		on_exit = function(_, code)
			vim.schedule(function()
				if code == 0 and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end)
		end,
	})
end

local function run(entry, pm)
	if vim.env.TMUX and vim.env.TMUX ~= "" then
		run_in_tmux(entry.dir, pm, entry.script)
	else
		run_in_nvim(entry.dir, pm, entry.script)
	end
end

local function open_picker()
	local root = vim.fs.root(0, { "pnpm-lock.yaml", "yarn.lock", "bun.lockb", "package-lock.json", ".git" })
		or vim.fn.getcwd()
	local pm = detect_pm(root)
	local entries = collect_scripts(root)

	if #entries == 0 then
		vim.notify("No package.json scripts found", vim.log.levels.WARN)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers.new({}, {
		prompt_title = "Run script (" .. pm .. ")",
		finder = finders.new_table({
			results = entries,
			entry_maker = function(entry)
				return {
					value = entry,
					display = string.format("[%s] %s → %s", entry.pkg, entry.script, entry.cmd),
					ordinal = entry.pkg .. " " .. entry.script,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				local sel = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if sel then run(sel.value, pm) end
			end)
			return true
		end,
	}):find()
end

vim.keymap.set("n", "<leader>pn", open_picker, { desc = "Run package script" })

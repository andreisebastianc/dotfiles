return {
	"mfussenegger/nvim-lint",
	-- BufReadPost is needed too: the config registers a lint-on-open autocmd,
	-- which never fired when the plugin itself only loaded on first save.
	event = { "BufReadPost", "BufWritePost" },
	config = function()
		local lint = require("lint")

		-- Ruby is deliberately absent: ruby-lsp already surfaces rubocop
		-- diagnostics via the project's bundle (right version, right plugins).
		-- Only register linters whose binary exists on this machine.
		local linters_by_ft = {
			go = { linter = "golangcilint", bin = "golangci-lint" },
			python = { linter = "pylint", bin = "pylint" },
		}

		lint.linters_by_ft = {}
		for ft, l in pairs(linters_by_ft) do
			if vim.fn.executable(l.bin) == 1 then
				lint.linters_by_ft[ft] = { l.linter }
			end
		end

		-- ESLint is handled separately (below) so it only runs when the project
		-- actually has an eslint config — keeps it quiet in non-eslint projects.
		local eslint_filetypes = {
			javascript = true,
			javascriptreact = true,
			["javascript.jsx"] = true,
			typescript = true,
			typescriptreact = true,
			["typescript.tsx"] = true,
			vue = true,
			svelte = true,
			astro = true,
		}

		local eslint_markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yaml",
			".eslintrc.yml",
			".eslintrc.json",
		}

		-- Directory of the nearest eslint config for the buffer, or nil.
		local function eslint_config_dir(bufnr)
			local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr or 0))
			if not dir or dir == "" then
				return nil
			end
			-- Stop at the home directory so a stray ~/.eslintrc doesn't
			-- enable eslint for every project on the machine.
			local found = vim.fs.find(eslint_markers, { upward = true, path = dir, stop = vim.uv.os_homedir() })[1]
			return found and vim.fs.dirname(found) or nil
		end

		local function has_eslint_config()
			return eslint_config_dir() ~= nil
		end

		-- Projects where eslint itself crashed (config imports a package that
		-- isn't installed, syntax error in the config, …). Whether a config
		-- loads can't be known without running it, so the first failure warns
		-- once and auto-linting then stays off for that project until a
		-- manual <leader>l retries it.
		local eslint_broken = {}

		local eslint_d = lint.linters.eslint_d
		local eslint_parser = eslint_d.parser
		eslint_d.parser = function(output, bufnr, ...)
			local trimmed = vim.trim(output)
			-- Real results are a JSON array; anything else is a crash report.
			if trimmed ~= "" and trimmed:sub(1, 1) ~= "[" and not trimmed:find("Could not find config file") then
				local dir = eslint_config_dir(bufnr)
				if dir and not eslint_broken[dir] then
					eslint_broken[dir] = true
					vim.notify(
						("eslint failed to run in %s — linting disabled there (<leader>l to retry):\n%s"):format(
							vim.fn.fnamemodify(dir, ":~"),
							vim.split(trimmed, "\n")[1]
						),
						vim.log.levels.WARN
					)
				end
				return {}
			end
			return eslint_parser(output, bufnr, ...)
		end

		local function run_eslint()
			if not eslint_filetypes[vim.bo.filetype] then
				return
			end
			local dir = eslint_config_dir()
			if dir and not eslint_broken[dir] then
				lint.try_lint("eslint_d")
			end
		end

		local function run_lint()
			lint.try_lint() -- filetype-configured linters (pylint, golangcilint)
			run_eslint()
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Heavier linters (pylint/golangci) run on save only.
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = lint_augroup,
			callback = run_lint,
		})

		-- ESLint is fast (eslint_d daemon), so surface its errors sooner:
		-- on file open and whenever you leave insert mode.
		vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave" }, {
			group = lint_augroup,
			callback = run_eslint,
		})

		vim.keymap.set("n", "<leader>l", function()
			-- Manual trigger gives a broken eslint project another chance.
			local dir = eslint_config_dir()
			if dir then
				eslint_broken[dir] = nil
			end
			run_lint()
		end, { desc = "Trigger linting for current file" })

		-- On-demand `eslint_d --fix` for the current file (not on save).
		local function eslint_fix()
			local bufnr = vim.api.nvim_get_current_buf()
			local file = vim.api.nvim_buf_get_name(bufnr)
			if file == "" then
				vim.notify("EslintFix: buffer has no file", vim.log.levels.WARN)
				return
			end
			if not (eslint_filetypes[vim.bo[bufnr].filetype] and has_eslint_config()) then
				vim.notify("EslintFix: no eslint config for this file", vim.log.levels.WARN)
				return
			end
			-- Persist the buffer first so eslint_d fixes the latest content.
			vim.cmd("silent noautocmd update")
			vim.system({ "eslint_d", "--fix", file }, { text = true }, function(obj)
				vim.schedule(function()
					-- exit 2 = fatal (bad config); 1 = unfixable problems remain (fine).
					if obj.code >= 2 then
						vim.notify("EslintFix: " .. (obj.stderr ~= "" and obj.stderr or "failed"), vim.log.levels.ERROR)
						return
					end
					vim.cmd("checktime " .. bufnr)
					run_lint()
				end)
			end)
		end

		vim.api.nvim_create_user_command("EslintFix", eslint_fix, { desc = "Run eslint_d --fix on the current file" })
		vim.keymap.set("n", "<leader>ef", eslint_fix, { desc = "ESLint --fix current file" })
	end,
}

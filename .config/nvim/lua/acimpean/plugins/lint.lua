return {
	"mfussenegger/nvim-lint",
	event = "BufWritePost",
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			ruby = { "rubocop" },
			go = { "golangcilint" },
			python = { "pylint" },
		}

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

		local function has_eslint_config()
			local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
			if not dir or dir == "" then
				return false
			end
			return #vim.fs.find(eslint_markers, { upward = true, path = dir }) > 0
		end

		local function run_eslint()
			if eslint_filetypes[vim.bo.filetype] and has_eslint_config() then
				lint.try_lint("eslint_d")
			end
		end

		local function run_lint()
			lint.try_lint() -- filetype-configured linters (rubocop, pylint, golangcilint)
			run_eslint()
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Heavier linters (rubocop/pylint/golangci) run on save only.
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

		vim.keymap.set("n", "<leader>l", run_lint, { desc = "Trigger linting for current file" })

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

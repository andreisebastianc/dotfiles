return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = { "ConformInfo", "FormatDisable", "FormatEnable", "FormatToggle" },
	keys = {
		{
			"<leader>mp",
			function() require("conform").format() end,
			mode = { "n", "v" },
			desc = "Format file or selection",
		},
		{ "<leader>tf", "<cmd>FormatToggle<cr>", desc = "Toggle format-on-save (buffer)" },
	},
	config = function()
		local conform = require("conform")
		local prettier = { "prettier" }

		conform.setup({
			default_format_opts = {
				-- Prettier from node_modules can take >1s on a cold start; the
				-- old 1000ms limit produced spurious "formatter timed out" errors.
				timeout_ms = 3000,
				-- Never fall back to the LSP's formatter. With "fallback",
				-- skipping prettier (no repo config) made conform hand the file
				-- to ts_ls, which reformatted it with tsserver's own style.
				-- Filetypes that *want* the LSP formatter opt in below.
				lsp_format = "never",
			},
			formatters_by_ft = {
				javascript = prettier,
				javascriptreact = prettier,
				typescript = prettier,
				typescriptreact = prettier,
				css = prettier,
				scss = prettier,
				less = prettier,
				html = prettier,
				json = prettier,
				jsonc = prettier,
				yaml = prettier,
				markdown = prettier,
				graphql = prettier,
				vue = prettier,
				svelte = prettier,
				handlebars = prettier,
				-- Ruby has no CLI formatter here on purpose: ruby-lsp formats
				-- with the project's own rubocop (right version + plugins).
				ruby = { lsp_format = "fallback" },
				eruby = { lsp_format = "fallback" },
				go = { "gofmt", "goimports" },
				zig = { "zigfmt" },
				lua = { "stylua" },
			},
			formatters = {
				prettier = {
					-- Only format when the project actually has a prettier
					-- config (rc file or a "prettier" key in package.json);
					-- conform also prefers the repo's node_modules prettier.
					require_cwd = true,
				},
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {}
			end,
		})

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, { desc = "Disable format-on-save (use ! for current buffer only)", bang = true })

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, { desc = "Re-enable format-on-save" })

		vim.api.nvim_create_user_command("FormatToggle", function()
			if vim.b.disable_autoformat or vim.g.disable_autoformat then
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
				vim.notify("Format-on-save enabled", vim.log.levels.INFO)
			else
				vim.b.disable_autoformat = true
				vim.notify("Format-on-save disabled (buffer)", vim.log.levels.INFO)
			end
		end, { desc = "Toggle format-on-save for current buffer" })
	end,
}

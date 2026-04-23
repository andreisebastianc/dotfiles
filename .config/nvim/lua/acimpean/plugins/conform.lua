return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	config = function()
		local conform = require("conform")
		local prettier = { "prettier" }

		conform.setup({
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
				ruby = { "rubocop" },
				eruby = { "rubocop" },
				go = { "gofmt", "goimports" },
				zig = { "zigfmt" },
				lua = { "stylua" },
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				}
			end,
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or selection" })

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

		vim.keymap.set("n", "<leader>tf", "<cmd>FormatToggle<cr>", { desc = "Toggle format-on-save (buffer)" })
	end,
}

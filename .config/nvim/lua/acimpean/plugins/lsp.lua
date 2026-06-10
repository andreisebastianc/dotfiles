return {
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = "VeryLazy",
		opts = function()
			-- This config runs on several machines with different toolchains.
			-- Only ask Mason for tools it can actually build/run here, so a
			-- missing toolchain doesn't produce install errors on every start.
			--
			-- Ruby tools are intentionally NOT Mason-managed: ruby-lsp/rubocop
			-- must match the project's Ruby, so install them per machine with
			-- `gem install ruby-lsp rubocop` (see cheatsheet).
			local ensure_installed = {
				"ember-language-server",
				"typescript-language-server",
				"css-variables-language-server",
				"zls",

				"prettier",
				"stylua",

				"eslint_d",
				"pylint",
			}

			-- Mason builds gopls/goimports with `go install`; golangci-lint is
			-- only useful alongside a Go toolchain anyway.
			if vim.fn.executable("go") == 1 then
				vim.list_extend(ensure_installed, { "gopls", "goimports", "golangci-lint" })
			end

			return {
				ensure_installed = ensure_installed,
				run_on_start = true,
				auto_update = false,
				start_delay = 3000,
			}
		end,
	},
}

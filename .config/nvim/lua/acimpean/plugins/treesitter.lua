return {
	"nvim-treesitter/nvim-treesitter",
	-- `master` is archived and incompatible with Neovim 0.12 (its indent
	-- queries broke). `main` is a rewrite: it only installs parsers/queries;
	-- highlighting, folding etc. are Neovim built-ins we enable ourselves.
	branch = "main",
	lazy = false, -- main does not support lazy-loading
	build = ":TSUpdate",
	-- Mason's setup() is what puts its bin dir (home of the tree-sitter CLI)
	-- on PATH. lazy.nvim doesn't guarantee load order between start plugins,
	-- so without this the CLI can be invisible when we install parsers.
	dependencies = { "mason-org/mason.nvim" },
	config = function()
		local ts = require("nvim-treesitter")

		local parsers = {
			"lua",
			"vim",
			"vimdoc",
			"dockerfile",
			"typescript",
			"tsx",
			"glimmer", -- handlebars
			"glimmer_typescript",
			"glimmer_javascript",
			"javascript",
			"html",
			"css",
			"markdown",
			"markdown_inline",
			"ruby",
			"embedded_template",
			"go",
			"gomod",
			"gosum",
			"zig",
		}

		-- Install only what's missing; needs the tree-sitter CLI (Mason
		-- installs it), a C compiler, curl and tar.
		local function install_missing()
			local installed = ts.get_installed("parsers")
			local missing = vim.tbl_filter(function(p)
				return not vim.tbl_contains(installed, p)
			end, parsers)
			if #missing > 0 then
				ts.install(missing)
			end
		end

		if vim.fn.executable("tree-sitter") == 1 then
			install_missing()
		else
			-- Fresh machine: Mason hasn't installed the CLI yet. Wait for
			-- mason-tool-installer to finish instead of failing with ENOENT.
			vim.api.nvim_create_autocmd("User", {
				pattern = "MasonToolsUpdateCompleted",
				once = true,
				callback = function()
					if vim.fn.executable("tree-sitter") == 1 then
						install_missing()
					else
						vim.notify(
							"tree-sitter CLI not found; parsers not installed. Check :Mason (tree-sitter-cli) or install it system-wide.",
							vim.log.levels.WARN
						)
					end
				end,
			})
		end

		-- Highlighting: start treesitter for any buffer whose language has a
		-- parser. start() throws when there's no parser — pcall keeps regex
		-- syntax highlighting as the fallback.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("acimpean_treesitter", { clear = true }),
			callback = function(ev)
				pcall(vim.treesitter.start, ev.buf)
			end,
		})

		-- Indentation stays on Neovim's built-in filetype indent scripts;
		-- treesitter indent (`ts.indentexpr()`) is opt-in on main and still
		-- experimental for JS/TS.
	end,
}

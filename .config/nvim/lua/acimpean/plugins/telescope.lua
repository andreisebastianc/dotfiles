return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>pf", function() require("telescope.builtin").find_files() end, desc = "Find files" },
		{ "<leader>pg", function() require("telescope.builtin").git_files() end, desc = "Git files" },
		{
			"<leader>ps",
			function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end,
			desc = "Grep search",
		},
	},
	config = function()
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = {
					"node_modules/",
					"%.git/",
					"dist/",
					"build/",
					"%.next/",
					"target/",
					"vendor/",
					"%.DS_Store",
				},
			},
			pickers = {
				find_files = {
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
			},
		})
	end,
}

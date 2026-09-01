return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree (diffview)" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (diffview)" },
		-- `git log -L` for the current line / visual selection.
		{ "<leader>gl", function() vim.cmd(".DiffviewFileHistory") end, desc = "Line history (diffview)" },
		{ "<leader>gl", ":DiffviewFileHistory<cr>", mode = "v", desc = "Selection history (diffview)" },
	},
	opts = {},
}

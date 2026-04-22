return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		delay = 300,
		-- Spec: group labels for my leader-prefixed mappings.
		-- Individual mappings keep their `desc` on the `vim.keymap.set` call
		-- where they're defined — which-key picks those up automatically.
		spec = {
			{ "<leader>p", group = "project / paste" },
			{ "<leader>x", group = "trouble / diagnostics" },
			{ "<leader>c", group = "code / trouble" },
			{ "<leader>z", group = "zen mode" },
			{ "<leader>m", group = "misc / format" },
			{ "<leader>g", group = "git" },
			{ "<leader>t", group = "toggles" },
			{ "<leader>y", group = "yank to clipboard" },
		},
	},
	keys = {
		{
			"<leader>?",
			function() require("which-key").show({ global = true }) end,
			desc = "Show all keymaps (which-key)",
		},
	},
}

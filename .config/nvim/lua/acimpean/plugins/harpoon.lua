return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add file to harpoon" })
		vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
			{ desc = "Harpoon quick menu" })

		vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon slot 1" })
		vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon slot 2" })
		vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end, { desc = "Harpoon slot 3" })
		vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end, { desc = "Harpoon slot 4" })

		-- Alt rather than Ctrl+Shift: tmux flattens C-S-p to C-p unless extended
		-- keys are on, and extended keys break Cmd+V paste in Ghostty on macOS.
		vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
		vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end, { desc = "Harpoon next" })
	end,
}

return {
	"lionyxml/gitlineage.nvim",
	dependencies = { "sindrets/diffview.nvim" },
	config = function()
		require("gitlineage").setup()
	end,
}

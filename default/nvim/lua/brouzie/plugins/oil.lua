return {
  "stevearc/oil.nvim",
  -- enabled = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
	require("oil").setup({
	  skip_confirm_for_simple_edits = true,
	  use_default_keymaps = false,
	  columns = { },
	  keymaps = {
		["g?"] = { "actions.show_help", mode = "n" },
		["<CR>"] = "actions.select",
		["<Esc>"] = "actions.close",
		["<leader>cd"] = "actions.cd",
		["<C-p>"] = "actions.preview",
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["<C-s>"] = "actions.refresh",
		["g."] = { "actions.toggle_hidden", mode = "n" },
		["<leader>l"] = "actions.refresh",
	  },
	  view_options = {
		show_hidden = true,
	  },
	})
  end
}

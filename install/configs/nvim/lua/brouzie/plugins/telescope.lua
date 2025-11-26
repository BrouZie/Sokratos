return {
	"nvim-telescope/telescope.nvim",
	branch = "master", -- using master to fix issues with deprecated to definition warnings
	-- '0.1.x' for stable ver.
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"LinArcX/telescope-env.nvim",
		"andrew-george/telescope-themes",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.load_extension("fzf")
		telescope.load_extension("themes")

		telescope.setup({
			defaults = {
				preview = { treesitter = false },
				color_devicons = true,
				sorting_strategy = "ascending",
				borderchars = {
					"─", -- top
					"│", -- right
					"─", -- bottom
					"│", -- left
					"┌", -- top-left
					"┐", -- top-right
					"┘", -- bottom-right
					"└", -- bottom-left
				},
				extensions = {
					themes = {
						enable_previewer = true,
						enable_live_preview = true,
						persist = {
							enabled = true,
							path = vim.fn.stdpath("config") .. "/lua/colorscheme.lua",
						},
					},
				},
				path_displays = { "smart" },
				layout_config = {
					height = 100,
					width = 400,
					prompt_position = "top",
					preview_cutoff = 40,
				},
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>G", builtin.live_grep, { desc = "Telescope live grep" })
		vim.keymap.set("n", "<leader>F", builtin.git_files, { desc = "Telescope git files" })
		vim.keymap.set("n", "<leader>M", builtin.man_pages, { desc = "Telescope man pages" })
		vim.keymap.set("n", "<leader>#", builtin.buffers)
		-- vim.keymap.set("n", "<leader>km", builtin.keymaps, { desc = "Telescope keymaps" })
		vim.keymap.set("n", "<leader>r", "<cmd>Telescope oldfiles<CR>", { desc = "Fuzzy find recent files" })
		vim.keymap.set("n", "<leader>pws", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end, { desc = "Find Connected Words under cursor" })

		vim.keymap.set(
			"n",
			"<leader>ths",
			"<cmd>Telescope themes<CR>",
			{ noremap = true, silent = true, desc = "Theme Switcher" }
		)
	end,
}

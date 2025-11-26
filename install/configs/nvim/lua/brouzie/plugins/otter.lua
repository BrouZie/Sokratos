return {
	{
		"jmbuhr/otter.nvim",
		ft = { "markdown", "markdown.mdx" },
		opts = {
			lsp = { diagnostics = { enabled = true } },
			buffers = { set_filetype = true},
		},
		config = function(_, opts)
			require("otter").setup(opts)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "markdown.mdx" },
				callback = function()
					require("otter").activate({ "python" }, true, true)
				end,
			})
		end,
	},
}

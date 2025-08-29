require("brouzie.utils")
vim.g.python3_host_prog = "/usr/bin/python3" -- Viktig for python provider

require("brouzie.core.options")
require("brouzie.core.keymaps")
require("brouzie.lazy")
require("current-theme")
require("brouzie.terminalpop")

-- Highlighting when yayænkin
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

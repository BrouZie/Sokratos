vim.g.python3_host_prog = "~/.venvs/nvim/bin/python"

require("brouzie.core.options")
require("brouzie.core.keymaps")
require("brouzie.lazy")
require("current-theme")
require("brouzie.terminalpop")
require("brouzie.todopop")

-- Highlighting when yayænkin
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

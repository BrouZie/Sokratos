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

-- Tell vim-dadbod-ui where to save scratchpads/results
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
vim.g.db_ui_use_nerd_fonts = 1

-- Define saved connections (Dadbod expands $ENV vars at runtime)
-- We'll load the .env before launching nvim so these get filled.
vim.g.dbs = {
  northwind = "mariadb://$MYSQL_USER:$MYSQL_PASSWORD@127.0.0.1:3306/$MYSQL_DATABASE",
	objective_db = "sqlite:" .. vim.fn.getcwd() .. "/sql/runs.db",
}

-- nvim-cmp + dadbod-completion: enable completion for SQL buffers
-- (Assumes you already use nvim-cmp)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql", "sqlite" },
  callback = function()
    local ok, cmp = pcall(require, "cmp")
    if ok then
      cmp.setup.buffer({
        sources = cmp.config.sources({
          { name = "vim-dadbod-completion" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  end,
})

vim.o.exrc = true
vim.o.secure = true

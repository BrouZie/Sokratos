vim.opt.undofile = true
vim.opt.winborder = "rounded"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorcolumn = false
vim.opt.guicursor = ""
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.confirm = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.exrc = true
vim.opt.secure = true

-- Copilot (uncomment and follow docs to enable Copilot)
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_enabled = false


--- Dadbod (SQL setup) ---

-- Save location of query buffers
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
vim.g.db_ui_use_nerd_fonts = 1

-- Define your database connections
-- .env variables can be sourced and read at runtime

vim.g.dbs = {
	-- Examples:
  -- northwind = "mariadb://$MYSQL_USER:$MYSQL_PASSWORD@127.0.0.1:3306/$MYSQL_DATABASE",
	-- sqlite3 = "sqlite:" .. vim.fn.getcwd() .. "/sqlite3.db",
}

-- Completions for SQL
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

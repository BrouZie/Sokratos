return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux"
  },
  config = function()
    vim.keymap.set("n", "<leader>ta", ":TestNearest<CR>", {})
    vim.keymap.set("n", "<leader>Ta", ":TestFile<CR>", {})
    vim.keymap.set("n", "<leader>at", ":TestSuite<CR>", {})
    vim.keymap.set("n", "<leader>la", ":TestLast<CR>", {})
    vim.keymap.set("n", "<leader>lat", ":TestVisit<CR>", {})
    vim.cmd("let test#strategy = 'vimux'")
  end,
}

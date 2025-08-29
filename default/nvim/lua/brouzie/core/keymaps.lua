vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<leader>f", ":Pick files<CR>")
map("n", "<leader>h", ":Pick help<CR>")
map("n", "<leader>e", ":Oil<CR>")
map("n", "<leader>o", ":update<CR> :source<CR>")
map("n", "<leader>w", ":write<CR>")
map("n", "<leader>q", ":quit<CR>")
map("n", "<leader>n", ":e $MYVIMRC<CR>")
map("n", "<leader>z", ":e ~/.config/bash/rc<CR>")
map("n", "<leader>s", ":e #<CR>")
map("n", "<leader>S", ":sf #<CR>")
map("t", "", "")
map("t", "", "")

map("n", "<leader>v", ":vsplit<CR>")
map("n", "<leader>cd", "<cmd>cd %:p:h|pwd<CR>")

-- Move between panes
map("n", "<c-k>", ":wincmd k<CR>")
map("n", "<c-j>", ":wincmd j<CR>")
map("n", "<c-h>", ":wincmd h<CR>")
map("n", "<c-l>", ":wincmd l<CR>")
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Indent "toggle"
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines collectively
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- Exec python
map("n", "<leader>x", "<cmd>w | !python3 %<CR>", { silent = true, desc = "makes file executable" })

-- Copy !pwd
map("n", "<leader>pp", function()
	local filePath = vim.fn.expand("%:~")
	vim.fn.setreg("+", filePath)
	print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- Toggle colorizer for buffer
map("n", "<leader>c", ":ColorizerToggle<CR>")

map(
	"n",
	"<leader>rp",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word cursor is on globally" }
)

-- Toggle LSP diagnostics visibility
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
	isLspDiagnosticsVisible = not isLspDiagnosticsVisible
	vim.diagnostic.config({
		virtual_text = isLspDiagnosticsVisible,
		underline = isLspDiagnosticsVisible,
	})
end, { desc = "Toggle LSP diagnostics" })


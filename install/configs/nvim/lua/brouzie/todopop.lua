local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	-- local width = opts.width or math.floor(vim.o.columns * 0.3)
	-- local height = opts.height or math.floor(vim.o.lines * 0.7)
	local width = 50
	local height = 25
	print(width, height)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_config = {
		relative = "editor",
		border = "bold",
		style = "minimal",
		width = width,
		height = height,
		col = col,
		row = row,
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

local pop_todo = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "" then
			-- Add your own path to a TODO-list file:
			vim.cmd.edit("~/Documents/2ndBrain/daily/TODO.md")
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Todopop", pop_todo, {})

vim.keymap.set("n", "<space>td", pop_todo)

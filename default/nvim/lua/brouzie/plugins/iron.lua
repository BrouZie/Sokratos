return {
  {
    -- iron.nvim (custom fork/branch)
    "g0t4/iron.nvim",
    branch = "fix-clear-repl",
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },

    config = function()
      local core  = require("iron.core")
      local ll    = require("iron.lowlevel")
      local marks = require("iron.marks")

      -- Ensure a REPL exists for the current filetype
      local function ensure_open()
        local meta = vim.b[0].repl
        if (not meta) or (not ll.repl_exists(meta)) then
          local ft = ll.get_buffer_ft(0)
          meta = ll.get(ft)
        end
        if not ll.repl_exists(meta) then
          meta = core.repl_for(ll.get_buffer_ft(0))
        end
        return meta
      end

      -- Ensure REPL exists and clear it (truncate scrollback hack)
      local function ensure_open_and_cleared()
        core.clear_repl()
        local meta = ensure_open()
        if not meta then return end
        local sb = vim.bo[meta.bufnr].scrollback
        vim.bo[meta.bufnr].scrollback = 1
        vim.bo[meta.bufnr].scrollback = sb
        return meta
      end

      local function clear_then(func)
        return function()
          ensure_open_and_cleared()
          func()
        end
      end

      -- Run top block, clear, then run current block
      local function send_top_block_then_current_block()
        local meta = ensure_open_and_cleared()
        if not meta then return end
        local cursor_position = vim.api.nvim_win_get_cursor(0)
        vim.cmd("norm gg")
        core.send_code_block()
        ensure_open_and_cleared()
        vim.api.nvim_win_set_cursor(0, cursor_position)
        core.send_code_block()
      end

      -- Keymaps: clear + send variants
      vim.keymap.set('n', '<leader>icm', clear_then(function() core.run_motion("send_motion") end), { desc = 'iron: clear → send motion' })
      vim.keymap.set('v', '<leader>icv', clear_then(function() core.send(nil, core.mark_visual()) end), { desc = 'iron: clear → send visual' })
      vim.keymap.set('n', '<leader>icf', clear_then(core.send_file),        { desc = 'iron: clear → send file' })
      vim.keymap.set('n', '<leader>icl', clear_then(core.send_line),        { desc = 'iron: clear → send line' })
      vim.keymap.set('n', '<leader>icp', clear_then(core.send_paragraph),   { desc = 'iron: clear → send paragraph' })
      vim.keymap.set('n', '<leader>icb', clear_then(core.send_code_block),  { desc = 'iron: clear → send block' })
      vim.keymap.set('n', '<leader>icn', clear_then(function() core.send_code_block(true) end), { desc = 'iron: clear → send block & next' })
      vim.keymap.set('n', '<leader>ict', clear_then(send_top_block_then_current_block), { desc = 'iron: clear → top block then current' })

      -- Non-clearing convenience
      vim.keymap.set('n', '<leader>ist', send_top_block_then_current_block, { desc = 'iron: top block then current' })
      vim.keymap.set('n', '<leader>icc', ensure_open_and_cleared,           { desc = 'iron: clear REPL' })

      -- WIP example: tee one command’s output to tmp file and paste back (commented)
      local function WIP_test_copy_cmd_output_using_tmp_file()
        local current_buf = vim.api.nvim_get_current_buf()
        local meta = ensure_open()
        if meta == nil then return end
        local tmpfile = vim.fn.tempname()

        local autocmd_id
        autocmd_id = vim.api.nvim_create_autocmd({ 'TermRequest' }, {
          buffer = meta.bufnr,
          desc = 'iron: capture command output via tmp file',
          callback = function()
            if string.sub(vim.v.termrequest, 1, 7) == '\x1b]133;D' then
              vim.api.nvim_del_autocmd(autocmd_id)
              local commented = {}
              local f = io.open(tmpfile)
              if f then
                for line in f:lines() do
                  table.insert(commented, "# " .. line)
                end
                f:close()
              end
              vim.api.nvim_set_current_buf(current_buf)
              vim.api.nvim_put(commented, 'l', true, true)
            end
          end
        })

        local function send_line()
          local row = vim.api.nvim_win_get_cursor(0)[1] - 1
          local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
          if not line or line == "" then return end
          local width = vim.fn.strwidth(line)
          marks.set { from_line = row, from_col = 0, to_line = row, to_col = math.max(0, width - 1) }
          core.send(nil, line .. " | tee " .. tmpfile)
        end

        send_line()
      end
      vim.keymap.set('n', '<leader>it', WIP_test_copy_cmd_output_using_tmp_file, { desc = 'iron: tee output of current line' })

      -- Helpers for cell navigation & insertion
      local function current_line_is_blank()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local ln = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
        return ln:match("^%s*$") ~= nil
      end

      local function is_line_before_blank_or_first_in_file()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        if row == 1 then return true end
        local prev = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
        return prev:match("^%s*$") ~= nil
      end

      local function get_all_block_deviders()
        local config = require("iron.config")
        local rd = config.repl_definition[vim.bo[0].filetype]
        if not rd then error("iron: no repl definition for this filetype") end
        local ds = rd.block_deviders
        if not ds or #ds == 0 then error("iron: no block divider(s) configured") end
        return ds
      end

      local function is_a_block_devider_line(line)
        for _, d in ipairs(get_all_block_deviders()) do
          if string.match(line, d) then return true end
        end
        return false
      end

      vim.keymap.set('n', '<leader>ij', function()
        local start = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_get_lines(0, start, 1000000, false)
        for i, ln in ipairs(lines) do
          if is_a_block_devider_line(ln) then
            local target = start + i + 1
            if i == #lines then target = target - 1 end
            vim.api.nvim_win_set_cursor(0, { target, 1 })
            break
          end
        end
      end, { desc = 'iron: next cell' })

      vim.keymap.set('n', '<leader>ik', function()
        local start = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_get_lines(0, 1, start - 1, false)
        for i = #lines, 1, -1 do
          if is_a_block_devider_line(lines[i]) then
            local target = start - (#lines - i) - 1
            vim.api.nvim_win_set_cursor(0, { math.max(target, 1), 1 })
            break
          end
        end
      end, { desc = 'iron: previous cell' })

      local function get_preferred_block_devider()
        local config = require("iron.config")
        local rd = config.repl_definition[vim.bo[0].filetype]
        if not rd then error("iron: no repl definition for this filetype") end
        local first = rd.block_deviders and rd.block_deviders[1]
        if not first or #first == 0 then error("iron: no block divider configured") end
        return first
      end

      vim.keymap.set('n', '<leader>ib', function()
        local divider = get_preferred_block_devider()
        if not current_line_is_blank() then
          vim.api.nvim_feedkeys("}", "n", false)
          vim.defer_fn(function()
            if not current_line_is_blank() then
              local k = vim.api.nvim_replace_termcodes("o<Esc>", true, false, true)
              vim.api.nvim_feedkeys(k, "n", false)
            end
            local keys = vim.api.nvim_replace_termcodes("o" .. divider .. "<CR><Esc>cc<Esc>", true, false, true)
            vim.api.nvim_feedkeys(keys, "n", false)
          end, 0)
        else
          if not is_line_before_blank_or_first_in_file() then
            local k = vim.api.nvim_replace_termcodes("o<Esc>", true, false, true)
            vim.api.nvim_feedkeys(k, "n", false)
          end
          local keys = vim.api.nvim_replace_termcodes("i" .. divider .. " <CR><Esc>cc<Esc>", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
        end
      end, { desc = 'iron: insert block divider' })

      local function open_repl_below()
        vim.cmd("IronRepl")  -- toggle
        vim.cmd("wincmd K")  -- move current window to top (REPL ends up bottom)
      end
      vim.keymap.set('n', '<leader>irj', open_repl_below, { desc = 'iron: open repl split below' })

      -- Shared shell definition
      local bash_repl_definition = {
        command = { "bash" },
        block_deviders = { "# %%" },
      }

      core.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            fish = { command = { "fish" }, block_deviders = { "# %%" } },
            sh   = bash_repl_definition,
            bash = bash_repl_definition,
            lua  = { command = { "lua" }, block_deviders = { "-- %%" } },
            python = {
              command = { "ipython", "--no-autoindent" },
              -- Treat each line as its own "cell" (interleaved output)
              format = function(lines, extras)
                local result = require("iron.fts.common").bracketed_paste_python(lines, extras)
                local filtered = vim.tbl_filter(function(l) return not string.match(l, "^%s*#") end, result)
                return filtered
              end,
              block_deviders = { "# %%", "#%%" },
            },
          },
          repl_filetype = function(_, ft) return ft end,
          repl_open_cmd = "vertical split",
        },

        -- iron.nvim built-in keymaps
        keymaps = {
          toggle_repl = "<space>ir",
          restart_repl = "<space>iR",
          send_motion = "<space>ism",
          visual_send = "<space>isv",
          send_file = "<space>isf",
          send_line = "<space>isl",
          send_paragraph = "<space>isp",
          send_until_cursor = "<space>isu",
          send_code_block = "<space>isb",
          send_code_block_and_move = "<space>isn",
          mark_motion = "<space>imm",
          mark_visual = "<space>imv",
          remove_mark = "<space>imd",
          send_mark = "<space>imr",
          cr = "<space>is<cr>",
          interrupt = "<space>iq",
          exit = "<space>ix",
        },

        highlight = { italic = true },
        ignore_blank_lines = true,
      }
    end,
  },
}

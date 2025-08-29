return {
  "goolord/alpha-nvim",
  dependencies = { "echasnovski/mini.icons" },

  config = function()
    local alpha     = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- 1) Your new ASCII art (23 lines × 44 cols)
    dashboard.section.header.val = {
      "****************=::::::::::=***************#",
      "************:-=======-========-:***********#",
      "*********:======::::::::::-=======:********#",
      "******+:=======*-:=+=:-::---========:+*****#",
      "*****:==========*+##*+--=##-+=========:****#",
      "***+-==========+*+++====+==*+==========-+**#",
      "**=============#*=-========#==============*#",
      "**:============#+**%%*-###*+=============:*#",
      "*:==============++==++-+==================:#",
      "*-===============+++=*+#=**================#",
      ":================++*+*#*+*=================:#",
      ":==============*++++==+=++==+==============:#",
      ":=========-----*+++++****+==::::===========:#",
      "*=======::::--:-=+++***++=::::-:::::=======#",
      "*:====:::::-::::=---=++=-:--:=--:::::=====:#",
      "**-===::::---:=--:---=--:-::-::-:-::::===-*#",
      "**:===::----:::::-::::::::-::::-:::-:-===:*#",
      "***-===-==:=::::::::+::-:-:::::--=---===-**#",
      "*****:====-=--::-:=::+++:-:-:::--+=++=:****#",
      "##****::+++=-:::-=-=-=+*=:=:-:=-*+++-:*****#",
      "***#***#+:++*=--+-==++--=-----++++:+##*****#",
      "##****#####-:*----------------=::#####*****#",
      "##***#####%%%%%%::::+%%*::::%%%%%#####*****#",
    }

    -- 2) Slice each 44-char line into 11 spans of 4 cols, each with its own I2A color:
    local gradient = {
      { "I2A1",   0,  4 },  -- red
      { "I2A3",   4,  8 },  -- yellow
      { "I2A7",   8, 12 },  -- orange
      { "I2A2",  12, 16 },  -- green
      { "I2A8",  16, 20 },  -- bright-green
      { "I2A6",  20, 24 },  -- cyan
      { "I2A9",  24, 28 },  -- bright-cyan
      { "I2A4",  28, 32 },  -- blue
      { "I2A10", 32, 36 },  -- light-blue
      { "I2A5",  36, 40 },  -- magenta
      { "I2A11", 40, 44 },  -- white
    }

    -- 3) Apply that same 11-span gradient to every header line:
    dashboard.section.header.opts.hl = {}
    for _ = 1, #dashboard.section.header.val do
      -- make a shallow copy so each line gets its own table
      table.insert(dashboard.section.header.opts.hl, vim.deepcopy(gradient))
    end

    -- 4) Buttons
    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file",     ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "λ  Find file",    ":Telescope find_files<CR>"),
      dashboard.button("r", "λ  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("q", "  Quit NVIM",    ":qa<CR>"),
    }

    alpha.setup(dashboard.opts)
  end,
}


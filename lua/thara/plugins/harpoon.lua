local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<leader>he", ui.toggle_quick_menu)

vim.keymap.set("n", "<leader>hp", function()  ui.nav_prev() end)
vim.keymap.set("n", "<leader>hn", function()  ui.nav_next() end)

require('harpoon').setup({
  menu = {
    -- width = vim.api.nvim_win_get_width(0) / 2,
    width = 100,
  }
})


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fs', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Allow to search in folder paths
vim.keymap.set('n', '<leader>fg', require("telescope").extensions.live_grep_args.live_grep_args, { noremap = true })


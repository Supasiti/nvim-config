local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Git files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })

vim.keymap.set('n', '<leader>fs', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end, { desc = '[F]ind [S]tring' })

vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })

-- Allow to search in folder paths
vim.keymap.set('n', '<leader>fg', require("telescope").extensions.live_grep_args.live_grep_args,
    { noremap = true, desc = '[F]ind [G]rep in folder' })

-- Allow to search within the buffer
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find,
    { desc = '[/] Fuzzily search in current buffer' })


require('telescope').setup {
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
    },
}

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'live_grep_args')


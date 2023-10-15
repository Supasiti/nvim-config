-- set file type to jsonc that can support comment
vim.api.nvim_create_autocmd(
    { "BufNewFile", "BufRead" },
    {
        group = vim.api.nvim_create_augroup('JsonSetFileType', { clear = true }),
        pattern = "*.json",
        callback = function()
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_option(buf, "filetype", "jsonc")
        end
    }
)

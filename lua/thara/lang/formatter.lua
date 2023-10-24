local M = {}

M.format = function()
    vim.lsp.buf.format({ async = false })
end

M.attach_formatter = function(group_name)
    return function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup(group_name, { clear = true }),
            buffer = bufnr,
            callback = M.format,
        })
    end
end

return M

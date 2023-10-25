local lsp_config = require('lspconfig')
local format_group = 'EslintFormat'

lsp_config.eslint.setup({
    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup(format_group, { clear = true }),
            buffer = bufnr,
            command = 'EslintFixAll'
        })
    end
})


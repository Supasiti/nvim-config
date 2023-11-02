local lsp_config = require('lspconfig')
local format_group = 'EslintFormat'

lsp_config.eslint.setup({
    settings = {
      autoFixOnSave = true,
    },
    on_attach = function(client, bufnr)
        -- need to set this
        -- Sometimes eslint doesn't register this capabilities.
        client.server_capabilities.documentFormattingProvider = true
        vim.notify("attaching eslint lsp", vim.log.levels.INFO)

        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup(format_group, { clear = true }),
            buffer = bufnr,
            command = 'EslintFixAll'
        })
    end
})


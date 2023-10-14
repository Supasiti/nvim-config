local lsp_config = require('lspconfig')

lsp_config.eslint.setup({
    -- sometimes the document doesn't allow eslint to format it
    on_init = function(client)
        client.resolved_capabilities.document_formatting = true
    end,

    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = 'EslintFixAll'
        })
    end
})


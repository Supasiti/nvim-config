local lsp_config = require('lspconfig')

lsp_config.gopls.setup {
    settings = {
        gopls = {
            buildFlags = { "-tags=session1 session2 session3 session4 session5 session6 session7 session8" }
        }
    }
}


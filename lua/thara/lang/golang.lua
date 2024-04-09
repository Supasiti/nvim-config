local lsp_config = require('lspconfig')
local fmt = require('thara.lang.formatter')

lsp_config.gopls.setup {
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    root_dir = lsp_config.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            buildFlags = { "-tags=session1 session2 session3 session4 session5 session6 session7 session8" },
            staticcheck = true,
        },
    },
    on_attach = fmt.attach_formatter("GoFormat"),
}

vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>")

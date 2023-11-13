local lsp_config = require('lspconfig')
local fmt = require("thara.lang.formatter")

lsp_config.templ.setup({
    on_attach = fmt.attach_formatter("TemplFormat")
})

-- Sometimes Neovim hasn't registered templ file extension
vim.filetype.add({
    extension = {
        templ = 'templ',
    },
})

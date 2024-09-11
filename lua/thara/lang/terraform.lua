require("lspconfig").terraformls.setup {
    on_attach = function()
        vim.notify("attached terraformls lsp", vim.log.levels.INFO)
    end,
}

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.tf", "*.tfvars" },
    callback = function()
        vim.lsp.buf.format()
    end,
})

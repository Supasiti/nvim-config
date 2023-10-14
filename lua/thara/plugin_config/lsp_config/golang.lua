local lsp_config = require('lspconfig')

local format_go = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- format
    vim.api.nvim_exec2("%!gofmt", { output = false })

    if vim.v.shell_error > 0 then
        vim.api.nvim_exec2("undo", { output = false })
        vim.api.nvim_win_set_cursor(0, cursor_pos) -- reset the cursor
        return
    end

    -- organise imports
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
end


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
    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("GoFormat", {}),
            buffer = bufnr,
            callback = format_go,
        })
    end,
}

local lsp_config = require('lspconfig')

local format_py = function(ev)
    -- Use autopep8 command to change the file and then tell nvim to reload
    local command = { "autopep8", "--in-place", ev.match, "--max-line-length", "120" }
    vim.fn.jobstart(command, {
        stdout_buffered = true,
        on_stdout = function()
            -- Use :checktime to sync buffer with the file that is just written by autopep8
            vim.cmd("checktime")
            print("formatted")
        end
    })
end

lsp_config.pyright.setup({
    -- This is for auto formatting without null-ls
    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup('PythonFormat', { clear = true }),
            buffer = bufnr,
            callback = format_py
        })
    end,
    filetypes = { "python" }
})

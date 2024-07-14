local lsp_config = require('lspconfig')
local fmt = require('thara.lang.formatter')

local settings = {
    analyses = {
        unusedparams = true,
    },
    buildFlags = { "-tags=session0 session1 session2 session3 session4 session5 session6 session6Bonus session7 session8" },
    staticcheck = true,
}
local test_flags = { "-tags", "session0 session1 session2" }

lsp_config.gopls.setup {
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    root_dir = lsp_config.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = settings,
    },
    on_attach = fmt.attach_formatter("GoFormat"),
}

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.go" },
    group = vim.api.nvim_create_augroup("Gopher", { clear = true }),
    callback = function()
        vim.notify("set keymaps for Go")
        vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>")

        local gopher = require('thara.lang.gopher')

        -- add Go specific commands
        vim.api.nvim_create_user_command("GoAddTest", gopher.add_test, {})

        -- run a single test
        -- add keymap
        vim.api.nvim_create_user_command("GoRunTest", function()
            gopher.run_test(test_flags)
        end, {})

        vim.keymap.set("n", "<leader>tt", "<CMD>GoRunTest<CR>", {
            desc = "Run a single [T]est"
        })

        -- run all tests in a file?
    end
})

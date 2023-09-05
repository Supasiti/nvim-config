local lsp = require('lsp-zero').preset('recommended')

lsp.ensure_installed({
    'tsserver',
    'eslint',
    'html',
    'jsonls',
    'gopls',
    'lua_ls',
    'rust_analyzer'
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        {
            name = 'cmdline',
            option = {
                ignore_cmds = { 'Man', '!' }
            }
        }
    })
})

cmp.setup({
    -- add border to code completion float
    window = {
        completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    }
})


lsp.set_preferences({
    sign_icons = {}
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.on_attach(function(_client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc, remap = false })
    end

    nmap("<leader>ca", function() vim.lsp.buf.code_action() end, "[C]ode [A]ction")
    nmap("<leader>rn", function() vim.lsp.buf.rename() end, "[R]e[n]ame")

    -- Go to definitions and references
    nmap("gd", function() vim.lsp.buf.definition() end, "[G]oto [D]efinition")
    nmap("gr", function() vim.lsp.buf.references() end, "[G]oto [R]eferences")
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap("K", function() vim.lsp.buf.hover() end, "Hover definition")
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    nmap("<leader>ws", function() vim.lsp.buf.workspace_symbol() end, "[W]orkspace [S]ymbol")

    -- Errors inspection
    nmap("<leader>vd", function() vim.diagnostic.open_float() end, "Open Float")
    nmap("[d", function() vim.diagnostic.goto_next() end, "Goto Next")
    nmap("]d", function() vim.diagnostic.goto_prev() end, "Goto Prev")

    -- Formatting
    nmap("<leader>f", function()
        vim.lsp.buf.format { async = true }
        print('formatted')
    end, "[F]ormat")
end)

-- (Optional) Configure lua language server for neovim
local lsp_config = require('lspconfig')

lsp_config.lua_ls.setup(lsp.nvim_lua_ls())

lsp_config.eslint.setup({
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = 'EslintFixAll'
        })
    end
})

lsp.format_on_save({
    servers = {
        ['rust_analyzer'] = { 'rust' },
        ['gopls'] = { 'go' },
        -- if you have a working setup with null-ls
        -- you can specify filetypes it can format.
        -- ['null-ls'] = {'javascript', 'typescript'},
    }
})

lsp.setup()

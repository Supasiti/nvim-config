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
local capabilities = require('cmp_nvim_lsp').default_capabilities() --nvim-cmp

-- set up code snippet
require('luasnip.loaders.from_vscode').lazy_load()
local luasnip = require('luasnip')

local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    -- scroll in document
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),

    -- jump to next snippet placeholder
    ['<C-k>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(1) then
            luasnip.jump(1)
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<C-j>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end, { 'i', 's' }),
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
    -- completion options
    completion = {
        -- menu options: to see more info type :h completeopt
        completeopt = "menu,preview,noselect",
    },
    -- add border to code completion float
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    -- ordering is important
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'luasnip' },                 -- For luasnip users.
        { name = 'nvim_lsp_signature_help' }, -- For function signature help
        {
            name = 'buffer',
            keyword_length = 5
        },
    }),
    experimental = {
        native_menu = false,
        -- show the lighten test before select
        ghost_text = true,
    },
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

    -- Restart server
    nmap("<leader>rs", ":LspRestart<CR>", "[R]estart [S]erver")

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

lsp_config.tsserver.setup({
    capabilities = capabilities,
    settings = {
        -- auto fill function signature
        completions = {
            completeFunctionCalls = true
        }
    }
})

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
            buffer = bufnr,
            callback = format_py
        })
    end,
    capabilities = capabilities,
    filetypes = { "python" }
})

lsp.format_on_save({
    servers = {
        ['rust_analyzer'] = { 'rust' },
        ['gopls'] = { 'go' },
    }
})

lsp.setup()

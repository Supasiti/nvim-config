local lsp = require('lsp-zero').preset('recommended')

require("mason-lspconfig").setup {
    ensure_installed = {
        'tsserver',
        'eslint',
        'html',
        'jsonls',
        'gopls',
        'lua_ls',
        'rust_analyzer'
    }
}

-- Setup neovim lua configuration
-- Need to be called before lsp_config
require('neodev').setup()

-- set default capabilities for all lsp
local lsp_config = require('lspconfig')
local lsp_defaults = lsp_config.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lsp_defaults.capabilities, -- default capabilities 
    require('cmp_nvim_lsp').default_capabilities() -- additional capabilities from completions
)

lsp.on_attach(function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc, remap = false })
    end

    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

    -- Go to definitions and references
    nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
    nmap('gi', vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap('gt', vim.lsp.buf.type_definition, "[G]oto [T]ype Definition")
    nmap("K", vim.lsp.buf.hover, "Hover definition")
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    nmap("<leader>ws", function() vim.lsp.buf.workspace_symbol() end, "[W]orkspace [S]ymbol")

    -- Errors inspection
    nmap("<leader>vdK", vim.diagnostic.open_float, "Open [F]loat")
    nmap("<leader>vdn", vim.diagnostic.goto_next, "Goto [N]ext")
    nmap("<leader>vdp", vim.diagnostic.goto_prev, "Goto [P]rev")
    nmap("<leader>vdl", "<cmd>Telescope diagnostics<cr>", "[L]ist")

    -- Restart server
    nmap("<leader>rs", ":LspRestart<CR>", "[R]estart [S]erver")

    -- Formatting
    nmap("<leader>f", function()
        vim.lsp.buf.format { async = true }
        print('formatted')
    end, "[F]ormat")
end)


-- lsp_config.tsserver.setup({
--     settings = {
--         -- auto fill function signature
--         completions = {
--             completeFunctionCalls = true
--         }
--     }
-- })

lsp.format_on_save({
    servers = {
        ['rust_analyzer'] = { 'rust' },
        ['gopls'] = { 'go' },
    }
})

lsp.setup()

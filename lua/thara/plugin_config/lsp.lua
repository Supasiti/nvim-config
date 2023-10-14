require("mason").setup()
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

-- Set up neovim lua configuration
-- Need to be called before lsp_config
require('neodev').setup()

-- Set up default capabilities for all LSPs
local lsp_config = require('lspconfig')
local lsp_defaults = lsp_config.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lsp_defaults.capabilities,                     -- default capabilities
    require('cmp_nvim_lsp').default_capabilities() -- additional capabilities from completions
)

-- Additional key binding associated with LSP
-- with auto command
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspKeyBinding', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf, remap = false }

        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
            if desc then
                desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc, remap = false })
        end

        nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

        -- Go to definitions and references
        nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
        nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
        nmap('gi', vim.lsp.buf.implementation, "[G]oto [I]mplementation")
        nmap('gt', vim.lsp.buf.type_definition, "[G]oto [T]ype Definition")
        nmap("K", vim.lsp.buf.hover, "Hover definition")
        nmap("<leader>ws", vim.lsp.buf.workspace_symbol, "[W]orkspace [S]ymbol")
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

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
    end
})

---
-- UI
---
local border_style = "rounded"

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = border_style }
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = border_style }
)

vim.diagnostic.config({
    float = { border = border_style }
})

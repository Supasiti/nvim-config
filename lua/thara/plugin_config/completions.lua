local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

-- set up code snippet
require('luasnip.loaders.from_vscode').lazy_load()
local luasnip = require('luasnip')

-- keybindings
local cmp_mappings = cmp.mapping.preset.insert({
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
-- This is used for autocompletion in command line tab
---@diagnostic disable-next-line: missing-fields
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

vim.opt.completeopt = { "menu", "menuone", "noselect" }

---@diagnostic disable-next-line: missing-fields
cmp.setup({
    -- Snippet engine is required for completions
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },

    -- mapping
    mapping = cmp_mappings,

    -- add border to code completion float
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    -- Sources tell the snippet engine where to get suggestions from
    -- The ordering here is used to sort into final list
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

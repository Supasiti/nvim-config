local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

-- set up code snippet
require('luasnip.loaders.from_vscode').lazy_load()
local luasnip = require('luasnip')

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


---@diagnostic disable-next-line: missing-fields
cmp.setup({
    -- mapping
    mapping = cmp_mappings,
    -- completion options
    ---@diagnostic disable-next-line: missing-fields
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


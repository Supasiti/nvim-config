-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        -- or                            , branch = '0.1.x',
        requires = {
            { 'nvim-lua/plenary.nvim' },
            { "nvim-telescope/telescope-live-grep-args.nvim" },
        },
        config = function()
            require("telescope").load_extension("live_grep_args")
        end
    }

    -- rose pine colour scheme
    use({ 'rose-pine/neovim', as = 'rose-pine' })

    -- tree sitter
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')
    use('theprimeagen/harpoon')
    use('mbbill/undotree')
    use('tpope/vim-fugitive')

    ---
    -- LSP Support
    ---
    use 'neovim/nvim-lspconfig'

    -- Automatically install LSPs to stdpath for neovim
    use('williamboman/mason.nvim', {
        -- Post-install update
        run = function()
            pcall(vim.api.nvim_exec2, 'MasonUpdate', { output = false })
        end,
    })
    use('williamboman/mason-lspconfig.nvim') -- To add capabilities to lspconfig

    -- Additional config for neovim specific suggestion
    use('folke/neodev.nvim')

    -- Autocompletion
    use('hrsh7th/nvim-cmp')     -- Required
    use('hrsh7th/cmp-nvim-lsp') -- Required
    use('L3MON4D3/LuaSnip')     -- Required

    -- Code Suggestion
    use('hrsh7th/cmp-path')   -- For path completion
    use('hrsh7th/cmp-buffer') -- Source from the buffer
    use('hrsh7th/cmp-cmdline')
    use('hrsh7th/cmp-nvim-lsp-signature-help')

    -- Snippet
    use('saadparwaiz1/cmp_luasnip')
    use('rafamadriz/friendly-snippets')

    ---
    -- Nice to have
    ---

    -- Code Navigation
    use {
        'ggandor/leap.nvim',
        config = function() require("leap").set_default_keymaps() end
    }

    -- lualine
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons' }
    }

    -- toggle comment - gcc for line and gbc for block
    use {
        'numToStr/Comment.nvim',
        config = function() require('Comment').setup() end
    }

    -- git signs
    use { 'lewis6991/gitsigns.nvim' }

    -- go extension
    use {
        "olexsmir/gopher.nvim",
        ft = "go",
        config = function(_, opts)
            require("gopher").setup(opts)
        end,
        build = function()
            vim.cmd [[silent! GoInstallDeps]]
        end,
    }

    -- templ extension
    use "vrischmann/tree-sitter-templ"

    -- markdown
    use "plasticboy/vim-markdown"
end)

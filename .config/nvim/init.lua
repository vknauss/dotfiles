vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.virtualedit = 'onemore'
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.cursorline = true

vim.fn['plug#begin'](vim.fn.stdpath('data') .. '/plugged')
vim.cmd [[
Plug 'tpope/vim-sensible'
Plug 'terminalnode/sway-vim-syntax'
Plug 'neoclide/jsonc.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'numToStr/Comment.nvim'
Plug 'altercation/vim-colors-solarized'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-nvim-lua'
" Plug 'romainl/vim-qf'
Plug 'folke/neodev.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'loctvl842/monokai-pro.nvim'
Plug 'tpope/vim-fugitive'

" neo-tree deps
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', {'branch': 'v2.x'}
]]
vim.fn['plug#end']()

require('Comment').setup()

require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
    },
}

local function has_words_before()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function feedkey(str, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, true , true), mode or '', true)
end

local cmp = require('cmp')
cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
        end
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
        ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
        -- C-b (back) C-f (forward) for snippet placeholder navigation.
        ['<C-Space>'] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping({i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
                fallback()
            end
        end,
            s = cmp.mapping.confirm({ select = true }),
        }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if #cmp.get_entries() == 1 then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                else
                    cmp.select_next_item()
                end
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)")
            elseif has_words_before() then cmp.complete() if #cmp.get_entries() == 1 then cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }) end else fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif  vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'nvim_lsp_signature_help' }
    }, {
        { name = 'buffer' }
    })
}

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
mapping = cmp.mapping.preset.cmdline(),
sources = {
  { name = 'buffer' }
}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
mapping = cmp.mapping.preset.cmdline(),
sources = cmp.config.sources({
  { name = 'path' }
}, {
  { name = 'cmdline' }
})
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('neodev').setup()

local lspconfig = require 'lspconfig'
lspconfig.clangd.setup {
    capabilities = capabilities,
    cmd = {
        "clangd",
        "--header-insertion=never"
    }
}
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    severity_sort = true,
}
lspconfig.tsserver.setup {
    capabilities = capabilities,
}
lspconfig.pylsp.setup {
    capabilities = capabilities,
}

-- https://github.com/neovim/nvim-lspconfig
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.diagnostic.config({
    update_in_insert = true,
})
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', '<Plug>(qf_qf_toggle)')

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

--[[ vim.api.nvim_create_autocmd('DiagnosticChanged', {
    callback = function()
        vim.diagnostic.setqflist({ open = false })
    end
}) ]]

require('neo-tree').setup {
    close_if_last_window = true,
    default_component_configs = {
        icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰉖",
            folder_empty_open = "󰷏",
            -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
            -- then these will never be used.
            default = "*",
            highlight = "NeoTreeFileIcon"
        },
        modified = {
            symbol = "[+] ",
            highlight = "NeoTreeModified",
        },
        name = {
            trailing_slash = false,
            highlight_opened_files = false, -- Requires `enable_opened_markers = true`. 
            -- Take values in { false (no highlight), true (only loaded), 
            -- "all" (both loaded and unloaded)}. For more information,
            -- see the `show_unloaded` config of the `buffers` source.
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
        },
        git_status = {
            symbols = {
                -- Change type
                added     = "✚", -- NOTE: you can set any of these to an empty string to not show them
                deleted   = "✖",
                modified  = "",
                renamed   = "󰁕",
                -- Status type
                untracked = "",
                ignored   = "",
                unstaged  = "󰄱",
                staged    = "",
                conflict  = "",
            },
            align = "right",
        },
    },
    filesystem = {
        -- find_by_full_path_words = true,
        use_libuv_file_watcher = true
    }
}

require('ibl').setup {
    indent = {
        char = '▏',
    },
    scope = {
        show_start = false,
        show_end = false,
    }
}

require('monokai-pro').setup {
    transparent_background = false,
    devicons = false,
    filter = 'spectrum',
    plugins = {
        indent_blankline = {
            context_highlight = 'default',
            context_start_underline = false,
        }
    },
    override = function(c)
        return {
            ColorColumn = { bg = c.editor.background },
            IblIndent = { fg = c.base.dimmed4 },
            IblScope = { fg = c.base.dimmed1 },
        }
    end
}

vim.cmd.colorscheme('monokai-pro')

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'monokai-pro',
        globalstatus = true,
        section_separators = {
            left = '',
            right = ''
        },
        component_separators = {
            left = '│',
            right = '│',
        },
    },
    sections = {
        lualine_a = { { 'filename', separator = { left = '', right = '' }, right_padding = 2 } },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { },
        lualine_x = { 'location', 'progress' },
        lualine_y = { 'diagnostics', 'filetype' },
        lualine_z = { { 'mode', separator = { left = '', right = '' }, right_padding = 2 } },
    },
    winbar = {
        lualine_a = { { 'filename', separator = { left = '', right = '' }, right_padding = 2 } },
        lualine_b = { },
        lualine_c = { },
        lualine_x = { },
        lualine_y = { },
        lualine_z = { },
    },
    inactive_winbar = {
        lualine_a = { { 'filename', separator = { left = '', right = '' }, right_padding = 2 } },
        lualine_b = { },
        lualine_c = { },
        lualine_x = { },
        lualine_y = { },
        lualine_z = { },
    },
}

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
-- vim.opt.laststatus = 3
vim.g.neo_tree_remove_legacy_commands = 1

vim.fn['plug#begin'](vim.fn.stdpath('data') .. '/plugged')
vim.cmd [[
" Plug 'tpope/vim-sensible'
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
Plug 'folke/trouble.nvim'
Plug 'p00f/clangd_extensions.nvim'
Plug 'elkowar/yuck.vim'

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
            ['<CR>'] = cmp.mapping(function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                    -- cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    --[[ if #cmp.get_entries() == 1 then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                    else ]]
                        cmp.select_next_item()
                    -- end
                elseif vim.fn["vsnip#jumpable"](1) == 1 then
                    feedkey("<Plug>(vsnip-jump-next)")
                --[[ elseif vim.fn["vsnip#available"](1) == 1 then
                    feedkey("<Plug>(vsnip-expand-or-jump)") ]]
                elseif has_words_before() then
                    cmp.complete()
                    if #cmp.get_entries() == 1 then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                    end
                else
                    fallback()
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
        }),
    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.recently_used,
            require("clangd_extensions.cmp_scores"),
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
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
        'clangd',
        '--header-insertion=never',
        '--background-index',
        '--log=error',
    }
}
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    severity_sort = true,
}
lspconfig.ts_ls.setup {
    capabilities = capabilities,
}
lspconfig.pylsp.setup {
    capabilities = capabilities,
}
lspconfig.jsonls.setup {
    capabilities = capabilities,
}
lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
}

-- https://github.com/neovim/nvim-lspconfig
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.diagnostic.config {
    update_in_insert = true,
    severity_sort = true,
}
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- vim.keymap.set('n', '<space>q', '<Plug>(qf_qf_toggle)')
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist)

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
            vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration { reuse_win = true } end, opts)
            vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition { reuse_win = true } end, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation { reuse_win = true } end, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set('n', '<space>D', function() vim.lsp.buf.type_definition { reuse_win = true } end, opts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        end,
    })

local trouble = require 'trouble'
trouble.setup {
    open_no_results = true,
    focus = true,
    auto_preview = false,
    preview = {
        type  = 'float',
        relative = 'editor',
    },
    win = {
        type  = 'split',
        relative = 'win',
    },
}
vim.keymap.set('n', '<space>t', function() trouble.toggle('diagnostics') end)

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  callback = function()
    vim.cmd([[Trouble qflist open]])
  end,
})

--[[ vim.api.nvim_create_autocmd('DiagnosticChanged', {
    callback = function()
        local qf_info = vim.fn.getqflist({ title = 0, id = 0 })
        local diagnostics = vim.diagnostic.get()
        table.sort(diagnostics, function(e0, e1)
            return e0.severity > e1.severity or (e0.severity == e1.severity and (e0.bufnr < e1.bufnr or (e0.bufnr == e1.bufnr and (e0.lnum < e1.lnum or (e0.lnum == e1.lnum and (e0.col < e1.col))))))
        end)

        local qf_items = vim.diagnostic.toqflist(diagnostics)

        vim.schedule(function()
            -- Replace the latest qflist if it was created by this autocmd so other
            -- qflists aren't buried due to frequently changing diagnostics.
            vim.fn.setqflist({}, qf_info.title == "All Diagnostics" and "r" or " ", {
                title = "All Diagnostics",
                items = qf_items,
            })

            -- Don't steal focus from other qflists. For example, when working through
            -- vimgrep results, you likely want :cnext to take you to the next match,
            -- rather than the next diagnostic. Use :cnew to switch to the diagnostic
            -- qflist when you want it.
            if qf_info.id ~= 0 and qf_info.title ~= "All Diagnostics" then
                vim.cmd.cold()
            end
        end)
    end,
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
        use_libuv_file_watcher = true,
        window = {
            mappings = {
                ['/'] = 'noop' -- disable fuzzy finder
            },
        },
    }
}
vim.keymap.set('n', '<space>n', function() vim.cmd('Neotree toggle') end)

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

local get_trouble_mode = function()
    local mode
    local views = (require 'trouble.view').get { open = true }
    for _, item in ipairs(views) do
        if item.view and item.view.win.win == vim.api.nvim_get_current_win() then
            mode = item.mode
            break
        end
    end
    return mode
end

local get_trouble_mode_formatted = function()
    local words = {}
    local mode = get_trouble_mode()
    if mode then
        words = vim.split(get_trouble_mode(), '[%W]')
        for i, word in ipairs(words) do
            words[i] = word:sub(1, 1):upper() .. word:sub(2)
        end
    end

    return table.concat(words, ' ')
end

local get_filename = function()
    return vim.fn.expand('%:~:.')
end

local get_working_directory = function()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end

require('lualine').setup {
    options = {
        icons_enabled = true,
        -- theme = 'monokai-pro',
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
        lualine_a = { { get_working_directory, separator = { left = '', right = '' }, right_padding = 2 } },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { },
        lualine_x = { 'location', 'progress' },
        lualine_y = { 'diagnostics', 'filetype' },
        lualine_z = { { 'mode', separator = { left = '', right = '' }, right_padding = 2 } },
    },
    winbar = {
        lualine_a = { { get_filename, separator = { left = '', right = '' }, right_padding = 2 } },
    },
    inactive_winbar = {
        lualine_a = { { get_filename, separator = { left = '', right = '' }, right_padding = 2 } },
    },
    extensions = {
        {
            filetypes = { 'qf' },
            winbar = { -- seems like inactive_winbar not needed
                lualine_a = {
                    { '', draw_empty = true, separator = { left = '' } }, -- do this so we can get the separator to the left but still get component separator after title
                    '%t', -- this gives [Quickfix List] or [Location List] where lualine 'filename' would just give [No Name]
                    function() return vim.w['quickfix_title'] or '' end
                },
                lualine_x = { 'location', 'progress' },
            },
        },
        {
            filetypes = { 'trouble' },
            winbar = {
                lualine_a = {
                    { '', draw_empty = true, separator = { left = '' } }, -- do this so we can get the separator to the left but still get component separator after title
                    function() return 'Trouble' end,
                    get_trouble_mode_formatted,
                },
                lualine_x = { 'location', 'progress' },
            },
        }
    },
}


-- vim.g.qf_auto_resize = 0
-- vim.g.qf_loclist_window_bottom = 0
--
vim.filetype.add({
    pattern = { [".*/hypr/.*%.conf"] = "hyprlang" }
})

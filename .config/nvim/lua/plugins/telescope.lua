return { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { -- telescope-fzf-native
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        -- ---------------------------
        -- Tree-sitter safe open fix
        -- ---------------------------
        local actions = require('telescope.actions')

        local open_after_tree = function(prompt_bufnr)
            vim.defer_fn(function()
                actions.select_default(prompt_bufnr)
            end, 100) -- Delay allows filetype and plugins to settle
        end

        -- [[ Configure Telescope ]]
        require('telescope').setup {
            defaults = {
                file_ignore_patterns = {
                    'node_modules',
                    '.DS_Store',
                    '.git',
                    'target',
                    '^vendor/',
                },
                mappings = {
                    i = { ['<CR>'] = open_after_tree },
                    n = { ['<CR>'] = open_after_tree },
                },
            },
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- Enable Telescope extensions if installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        -- Keymaps for builtin pickers
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search help' })
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Search keymaps' })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Search files' })
        vim.keymap.set('n', '<leader>fb', builtin.builtin, { desc = 'Search Telescope builtins' })
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Search current word' })
        vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = 'Search for string in files' })
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Search diagnostics' })
        vim.keymap.set('n', '<leader>fc', builtin.resume, { desc = 'Search continue' })
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Search Recent Files' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        -- Current buffer fuzzy find
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 0,
                previewer = false,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })

        -- Live grep in open files
        vim.keymap.set('n', '<leader>f/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
            }
        end, { desc = 'Search in Open Files' })

        -- Search Neovim config
        vim.keymap.set('n', '<leader>fn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = 'Search Neovim files' })
    end,
}

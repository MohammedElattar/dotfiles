return {
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end,
    },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require('mason-lspconfig').setup({
                automatic_enable = false,
                ensure_installed = {},
            })
        end,
    },
    {
        'neovim/nvim-lspconfig',
        opts = {
            servers = {
                lua_ls = {},

                intelephense = {
                    settings = {
                        intelephense = {
                            stubs = {
                                "Core",
                                "PDO",
                                "json",
                                "standard",
                                "wordpress",
                                "laravel",
                            },
                            diagnostics = {
                                undefinedTypes = false,
                                undefinedFunctions = false,
                                undefinedConstants = false,
                                undefinedClassConstants = false,
                                undefinedMethods = false,
                                undefinedProperties = false,
                            },
                        },
                    },
                },

                -- FIXED NAME
                tsserver = {},

                tailwindcss = {},

                lemminx = {
                    filetypes = { 'xml' },
                    settings = {
                        xml = {
                            catalogs = {},
                            server = {
                                workDir = "~/.cache/lemminx"
                            }
                        }
                    }
                },

                emmet_ls = {
                    filetypes = {
                        'html',
                        'typescriptreact',
                        'javascriptreact',
                        'css',
                        'scss',
                    },
                },

                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true,
                            analyses = {
                                unusedparams = true,
                            },
                            staticcheck = true,
                        },
                    },
                },
            },
        },

        config = function(_, opts)
            local telescope = require('telescope.builtin')

            -- ✅ NEW Neovim 0.11+ LSP setup
            for server, config in pairs(opts.servers) do
                config.capabilities =
                    require('blink.cmp').get_lsp_capabilities(config.capabilities)

                vim.lsp.config(server, config)
                vim.lsp.enable(server)
            end

            -- ✅ LSP Keymaps
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, {
                            buffer = event.buf,
                            desc = 'LSP: ' .. desc,
                        })
                    end

                    map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
                    map('gr', telescope.lsp_references, '[G]oto [R]eferences')
                    map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
                    map('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
                    map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
                    map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    local client = vim.lsp.get_client_by_id(event.data.client_id)

                    -- Highlight references
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = group,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = group,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({
                                    group = 'lsp-highlight',
                                    buffer = event2.buf,
                                })
                            end,
                        })
                    end

                    -- Inlay hints toggle
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                            )
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- Diagnostics UI
            if vim.g.have_nerd_font then
                local signs = { Error = '', Warn = '', Hint = '', Info = '' }
                for type, icon in pairs(signs) do
                    local hl = 'DiagnosticSign' .. type
                    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
                end
            end

            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            vim.o.updatetime = 250
        end,
    },
}

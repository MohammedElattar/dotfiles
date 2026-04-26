require("config")

-- auto confirm new packages installation
vim.g.vim_pack_auto_confirm = true

vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "stylua",
        "ts_ls",
        "intelephense",
        "phpactor",
        "gopls",
    },
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = {
                    "vim",
                    "require",
                },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

-- Intelephense: primary PHP LSP (completion, defs, etc.). Premium rename is unused.
-- Phpactor: second client on PHP buffers for workspace rename only. Diagnostics and
-- extra analyzers are turned off via init_options so Intelephense stays authoritative.
vim.lsp.config("phpactor", {
    init_options = {
        ["language_server.diagnostics_on_update"] = false,
        ["language_server.diagnostics_on_open"] = false,
        ["language_server.diagnostics_on_save"] = false,
        ["language_server_phpstan.enabled"] = false,
        ["language_server_psalm.enabled"] = false,
    },
})

vim.lsp.config("gopls", {
    settings = {
        gopls = {
            gofumpt = true,
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
})

if vim.g.have_nerd_font then
    local signs = { Error = "", Warn = "", Hint = "", Info = "" }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
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

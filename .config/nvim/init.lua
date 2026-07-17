require("config")

-- auto confirm new packages installation
vim.g.vim_pack_auto_confirm = true
if vim.env.KHATT ~= nil or vim.env.TERM_PROGRAM == "khatt" then
  vim.opt.termbidi = true
end

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
        "postgres_lsp",
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

-- Postgres LSP (postgres-language-server, formerly postgrestools).
-- Provides syntax errors, linting, type-checking and completion for SQL.
-- Override workspace_required so it also attaches to standalone .sql files
-- without needing a postgres-language-server.jsonc at the project root.
vim.lsp.config("postgres_lsp", {
    cmd = { "postgres-language-server", "lsp-proxy" },
    filetypes = { "sql" },
    root_markers = { "postgres-language-server.jsonc", ".git" },
    workspace_required = false,
})

-- Per-project DATABASE_URL: before opening a .sql buffer, walk up to find
-- the nearest .env and load DATABASE_URL from it into vim.env. The Postgres
-- LSP inherits vim.env on spawn, so no per-project init.lua edits needed.
-- Use .env itself as the marker (independent of where the jsonc lives, so
-- nested per-folder configs still resolve the project-root .env correctly).
-- Workflow per project: drop postgres-language-server.jsonc + a .env
-- containing DATABASE_URL=postgres://... in the repo root.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("postgres-lsp-dotenv", { clear = true }),
    pattern = "*.sql",
    callback = function(args)
        local envdir = vim.fs.root(args.buf, ".env")
        if not envdir then return end
        for line in io.lines(envdir .. "/.env") do
            local val = line:match("^%s*DATABASE_URL%s*=%s*(.*)%s*$")
            if val then
                val = val:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
                vim.env.DATABASE_URL = val
                return
            end
        end
    end,
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

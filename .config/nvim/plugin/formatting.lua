vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
    notify_on_error = false,
    format_on_save = false,
    formatters = {
        -- Force PostgreSQL dialect; default "sql" is generic and lower-quality.
        sql_formatter = {
            prepend_args = { "--language", "postgresql" },
        },
        -- sql-formatter inserts a space after identifiers before `(`, which
        -- breaks `sqlc.embed(...)`. Strip the space for known sqlc directives.
        fix_sqlc = {
            command = "sed",
            args = { "-E", "s/sqlc\\.(arg|embed|narg|slice|n)[[:space:]]+\\(/sqlc.\\1(/g" },
            stdin = true,
        },
    },
    formatters_by_ft = {
        lua = { "stylua" },

        python = { "isort", "black" },

        -- You can use 'stop_after_first' to run the first available formatter from the list
        javascript = { "prettier", stop_after_first = true },
        json = { "prettier", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        typescriptreact = { "prettier", stop_after_first = true },
        javascriptreact = { "prettier", stop_after_first = true },
        html = { "prettier", stop_after_first = true },
        css = { "prettier", stop_after_first = true },
        http = { "kulala-fmt", stop_after_first = true },

        -- Postgres LSP's formatter strips comments; use sql-formatter instead.
        -- fix_sqlc runs after to repair `sqlc.embed (x)` -> `sqlc.embed(x)`.
        sql = { "sql_formatter", "fix_sqlc" },
    },
})

vim.keymap.set("n", "<leader>f=", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

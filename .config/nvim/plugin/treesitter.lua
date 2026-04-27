vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- nvim-treesitter rewrite (0.12+): setup() only honors install_dir; highlight/indent
-- flags are ignored. Use vim.treesitter.start() per filetype (see autocommands.lua)
-- and install parsers explicitly.
local ts_langs = {
    "lua",
    "php",
    "blade",
    "svelte",
    "typescript",
    "tsx",
    "jsx",
    "ecma",
    "css",
    "html",
    "html_tags",
    "javascript",
    "json",
    "markdown",
}

require("nvim-treesitter").setup({})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        require("nvim-treesitter").install(ts_langs)
    end,
})

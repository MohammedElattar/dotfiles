return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = true, -- 🔥 IMPORTANT
    opts = {
        auto_install = true,
        ensure_installed = {
            'lua',
            'http'
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
    },
}

return {
    'mistweaverco/kulala.nvim',
    ft = { 'http' },
    config = function()
        local kulala = require 'kulala'
        kulala.setup {
            global_keymaps = true,
            lsp = {
                formatter = true,
            },
            ui = {
                display_mode = "split",
                split_direction = "horizontal"
            }
        }
    end,
}

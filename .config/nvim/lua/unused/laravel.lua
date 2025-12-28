return {
    "adalessa/laravel.nvim",
    ft = "php",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "neovim/nvim-lspconfig",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-neotest/nvim-nio"
    },
    config = function()
        require("laravel").setup({})
    end,
}

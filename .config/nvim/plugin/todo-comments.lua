vim.pack.add({ "https://github.com/folke/todo-comments.nvim" })

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        require("todo-comments").setup({
            signs = false,
        })
    end,
})

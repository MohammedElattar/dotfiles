-- Svelte: keep legacy :syntax alongside Treesitter so indent/ft plugins using synID()
-- stay correct; highlighter may attach asynchronously.
local buf = vim.api.nvim_get_current_buf()
local function legacy_syntax_on()
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "svelte" then
        vim.bo[buf].syntax = "ON"
    end
end
legacy_syntax_on()
vim.schedule(legacy_syntax_on)
vim.defer_fn(legacy_syntax_on, 100)

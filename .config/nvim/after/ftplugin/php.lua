-- indent/php.vim must run with legacy :syntax (see $VIMRUNTIME/indent/php.vim). Treesitter
-- highlighting turns that off; the highlighter can also settle asynchronously, so repeat.
local buf = vim.api.nvim_get_current_buf()
local function legacy_syntax_on()
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "php" then
        vim.bo[buf].syntax = "ON"
    end
end
legacy_syntax_on()
vim.schedule(legacy_syntax_on)
vim.defer_fn(legacy_syntax_on, 100)

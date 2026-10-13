-- vim-tmux-navigator for herdr: at a split edge, <C-h/j/k/l> moves into the neighbouring herdr pane.
-- Outside herdr this file does nothing, so vim-tmux-navigator keeps handling tmux.
if not vim.env.HERDR_PANE_ID then
    return
end

local function navigate(wincmd, direction)
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(wincmd)
    if vim.api.nvim_get_current_win() == win then
        vim.system({ "herdr", "pane", "focus", "--direction", direction, "--pane", vim.env.HERDR_PANE_ID })
    end
end

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    vim.keymap.set("n", "<C-" .. key .. ">", function()
        navigate(key, direction)
    end, { desc = "Navigate " .. direction .. " (nvim/herdr)" })
end

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
})

local telescope = require("telescope")

telescope.setup({
    defaults = {
        file_ignore_patterns = { "node_modules", ".git", "target", "vendor", "build" },
    },
})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim"
        if not vim.loop.fs_stat(dir .. "/build/libfzf.so") then
            local cwd = vim.fn.getcwd()
            vim.fn.chdir(dir)
            vim.fn.system(
                vim.loop.os_uname().sysname:match("Windows")
                        and { "cmake", "-S.", "-Bbuild", "-DCMAKE_BUILD_TYPE=Release" }
                    or { "make" }
            )
            vim.fn.chdir(cwd)
        end
        pcall(require("telescope").load_extension, "fzf")
    end,
})

local builtin = require("telescope.builtin")
local lsp_util = require("vim.lsp.util")

--- Jump to a single location or populate quickfix when there are many.
--- Returns true if we jumped/opened qflist, false if the result was empty.
local function jump_to_locations(result, client, win, bufnr, tagname, from)
    if result == nil then return false end
    local locations = vim.islist(result) and result or { result }
    local items = lsp_util.locations_to_items(locations, client.offset_encoding)
    if vim.tbl_isempty(items) then return false end
    if #items == 1 then
        local item = items[1]
        local b = item.bufnr or vim.fn.bufadd(item.filename)
        vim.cmd("normal! m'")
        vim.fn.settagstack(vim.fn.win_getid(win), { items = { { tagname = tagname, from = from } } }, "t")
        vim.bo[b].buflisted = true
        vim.api.nvim_win_set_buf(win, b)
        vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
        vim._with({ win = win }, function()
            vim.cmd("normal! zv")
        end)
        return true
    end
    vim.fn.setqflist({}, " ", { title = "LSP locations", items = items })
    vim.cmd("botright copen")
    return true
end

--- On PHP we attach phpactor for rename; `gd` would merge definition results from both servers.
--- Use Intelephense only here so navigation matches a single LSP.
--- On Go, gopls' definition at an interface method call goes to the interface, not the
--- concrete implementation. Try `implementation` first and fall back to `definition`.
local function lsp_goto_definition()
    local ft = vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local tagname = vim.fn.expand("<cword>")
    local from = vim.fn.getpos(".")
    from[1] = bufnr

    if ft == "go" then
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
        if #clients == 0 then
            vim.lsp.buf.definition()
            return
        end
        local client = clients[1]
        local params = lsp_util.make_position_params(win, client.offset_encoding)
        client:request("textDocument/implementation", params, function(_, impl_result)
            if jump_to_locations(impl_result, client, win, bufnr, tagname, from) then return end
            client:request("textDocument/definition", params, function(err, def_result)
                if err then
                    vim.notify(("[LSP][%s] %s"):format(client.name, err.message or tostring(err)), vim.log.levels.ERROR)
                    return
                end
                if not jump_to_locations(def_result, client, win, bufnr, tagname, from) then
                    vim.notify("No locations found", vim.log.levels.INFO)
                end
            end, bufnr)
        end, bufnr)
        return
    end

    if ft ~= "php" then
        vim.lsp.buf.definition()
        return
    end
    local method = "textDocument/definition"
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense", method = method })
    if #clients == 0 then
        vim.lsp.buf.definition()
        return
    end
    local client = clients[1]
    local params = lsp_util.make_position_params(win, client.offset_encoding)
    client:request(method, params, function(err, result, _)
        if err then
            vim.notify(("[LSP][%s] %s"):format(client.name, err.message or tostring(err)), vim.log.levels.ERROR)
            return
        end
        if not jump_to_locations(result, client, win, bufnr, tagname, from) then
            vim.notify("No locations found", vim.log.levels.INFO)
        end
    end, bufnr)
end

local function lsp_rename()
    if vim.bo.filetype == "php" then
        local clients = vim.lsp.get_clients({ bufnr = 0, name = "phpactor", method = "textDocument/rename" })
        if #clients > 0 then
            vim.lsp.buf.rename(nil, { name = "phpactor" })
            return
        end
    end
    vim.lsp.buf.rename()
end

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Search for string in files" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Search Recent Files" })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find existing buffers" })
vim.keymap.set("n", "gd", lsp_goto_definition, { desc = "Goto definition" })
vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "Goto references" })
vim.keymap.set("n", "<leader>rn", lsp_rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

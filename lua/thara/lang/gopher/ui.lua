local popup = require("plenary.popup")

local M = {}
local go_win_id = nil

function M.close_popup()
    if go_win_id ~= nil then
        vim.api.nvim_win_close(go_win_id, true)
        go_win_id = nil
    end
end

-- @param content string[] array of lines
function M.show_popup(content)
    local height = 32
    local px = 40
    local width = vim.o.columns - (2 * px)
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    go_win_id = popup.create(content, {
        title = "Output",
        highlight = "OutputWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = px,
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    local bufnr = vim.api.nvim_win_get_buf(go_win_id)
    vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<ESC>",
        "<Cmd>lua require('thara.lang.gopher.ui').close_popup()<CR>",
        { silent = false }
    )
end

return M

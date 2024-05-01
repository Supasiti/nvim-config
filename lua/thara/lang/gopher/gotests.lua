local ui = require('thara.lang.gopher.ui')
local M = {}

-- return the root of tree
-- @param bufnr Buffer
local function get_root(bufnr)
    local parser = vim.treesitter.get_parser(bufnr, "go", {})
    local tree = parser:parse()[1]
    return tree:root()
end

-- check if the cursor is in range
-- @param cursor number[] { row, col }
-- @param range number[] { start row, start col, end row, end col }
-- @return boolean
local function intersect(cursor, range)
    -- note range is zero indexed but cursor row is 1 indexed
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]

    if cursor_row < range[1] then
        return false
    end

    if cursor_row > range[3] then
        return false
    end

    if cursor_row == range[1] and cursor_col < range[2] then
        return false
    end

    if cursor_row == range[3] and cursor_col > range[4] then
        return false
    end

    return true
end

-- Return a function name on the cursor or nil
-- @return string|nil
local function get_func_name_on_cursor()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= "go" then
        vim.notify("incorrect file type")
        return nil
    end

    local query = vim.treesitter.query.parse(
        "go",
        [[
            ((function_declaration
                name: (identifier) @func.name
            )) @func.declaration

            ((method_declaration
                name: (field_identifier) @method.name
            )) @method.declaration
        ]]
    )

    local root = get_root(bufnr)
    local cursor = vim.api.nvim_win_get_cursor(0)

    -- match the exact pattern
    for _, match in query:iter_matches(root, bufnr, 0, -1) do
        local name, dec_node

        -- there should only be two types of nodes
        -- name or declaration
        for id, node in pairs(match) do
            local c = query.captures[id]
            local op = string.find(c, "name")

            if op ~= nil then
                name = vim.treesitter.get_node_text(node, bufnr)
                goto continue
            end

            -- this must be declaration node
            -- check if it contains the cursor
            local range = { node:range() }
            if intersect(cursor, range) then
                dec_node = node
            end

            ::continue::
        end

        -- return first match
        if dec_node ~= nil then
            return name
        end
    end

    -- if it gets here it didn't find any match
    vim.notify("cursor on func/method and execute the command again")
    return nil
end


function M.add_test()
    local fpath = vim.fn.expand "%"

    -- local fn_name = "^String$"
    local fn_name = get_func_name_on_cursor()
    if fn_name == nil then
        return
    end

    local pattern = "^" .. fn_name .. "$"

    local cmd = { "gotests", "-only", pattern, "-template", "testify", "-w", fpath }
    vim.fn.jobstart(cmd, {
        on_exit = function()
            -- Use :checktime to sync buffer with the file that is just written by gotests
            vim.cmd("checktime")
            vim.notify("unit test(s) generated")
        end
    })
end

-- @param test_flags string[]
function M.run_test(test_flags)
    local fpath = vim.fn.expand "%"
    local first_char = string.sub(fpath, 1, 1)
    if first_char ~= "." and first_char ~= "/" then
        fpath = "./" .. fpath
    end
    local dir = vim.fs.dirname(fpath)

    -- local fn_name = "^String$"
    local fn_name = get_func_name_on_cursor()
    if fn_name == nil then
        return
    end

    local pattern = "^" .. fn_name .. "$"
    local cmd = { "go", "test" }

    if test_flags ~= nil then
        for _, value in ipairs(test_flags) do
            table.insert(cmd, value)
        end
    end

    table.insert(cmd, "-run")
    table.insert(cmd, pattern)
    table.insert(cmd, dir)

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            -- data is a table a line
            if data then
                ui.show_popup(data)
            end
        end
    })
end

return M

require("lspconfig").tsserver.setup {
    settings = {
        -- auto fill function signature
        completions = {
            completeFunctionCalls = true
        }
    }
}

---
-- Jest runner
--
-- 1) Open both main and test files
-- 2) On the main file - run :JestRun
-- 3) Command: npm run test:unit (not on watch mode)
-- 4) Test buffer: <buffer id from test files>

local ns = vim.api.nvim_create_namespace("JestRunNS")

local function create_diagnostics(state, test_content)
    local diag = {}

    -- loop over the test file and mark diagnostic against test results
    for i, line in ipairs(test_content) do
        for _, res in ipairs(state.test_results) do
            local is_matched = string.find(line, res.title)
            local is_failed = res.status == "failed"

            if is_matched and is_failed then
                local msg = "Failed test"
                if #res.failureMessages > 0 then
                    msg = res.failureMessages[1]
                end

                table.insert(diag, {
                    lnum = i - 1,
                    col = 0,
                    message = msg,
                })
            end
        end
    end

    return diag
end

local function get_test_results(json)
    if #json.testResults == 0 then
        return {}
    end
    return json.testResults[1].assertionResults
end


-- will return 0 if not found
local function get_buf_by_client_id_and_name(client_id, buf_name)
    local buffers = vim.lsp.get_buffers_by_client_id(client_id)

    local result = 0
    for _, buf in ipairs(buffers) do
        if buf_name == vim.api.nvim_buf_get_name(buf) then
            result = buf
            break
        end
    end

    return result
end

--
-- Initialise the state of runner
-- If the test file doesnn't exist, it will create a buffer
--
local function init_state()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_buf_name = vim.api.nvim_buf_get_name(0)
    local test_buf_name = string.gsub(current_buf_name, "%.ts", ".test.ts")
    local test_buf = 0

    local clients = vim.lsp.get_active_clients({ bufnr = 0 })

    if #clients > 0 then
        test_buf = get_buf_by_client_id_and_name(clients[1].id, test_buf_name)

        if test_buf == 0 then
            vim.cmd("vnew")
            vim.cmd('e ' .. test_buf_name) -- will create a test file not exist
            test_buf = vim.api.nvim_get_current_buf()
        end
    end

    return {
        test_results = {},
        test_buf = test_buf,
        test_buf_name = test_buf_name,
        current_buf = current_buf,
    }
end

vim.api.nvim_create_user_command("JestRun", function()
    local cmd = vim.fn.split(vim.fn.input("Command: "), " ")

    local state = init_state()

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("JestRunTest", { clear = true }),
        buffer = state.current_buf,
        callback = function()
            vim.list_extend(cmd, { "--", "--json", state.test_buf_name })
            vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    -- get the line that start with {
                    local json_str = vim.tbl_filter(function(v)
                        return string.find(v, "^%{") ~= nil
                    end, data)

                    -- expect only one json object
                    state.test_results = get_test_results(vim.json.decode(json_str[1]))

                    local test_content = vim.api.nvim_buf_get_lines(state.test_buf, 0, -1, false)
                    local diag = create_diagnostics(state, test_content)

                    vim.diagnostic.set(ns, state.test_buf, diag)
                    vim.diagnostic.show()

                    print("Number of tests failed: " .. tostring(#diag))
                end
            })
        end
    })
end, {})


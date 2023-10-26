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
-- 2) Get the buffer id - :echo nvim_get_current_buf()
-- 3) On the main file - run :JestRun
-- 4) Command: npm run test:unit (not on watch mode)
-- 5) Test buffer: <buffer id from test files>

local function create_diagnostics (state, test_content)
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

local function get_test_results (json)
    if #json.testResults == 0 then
        return {}
    end
    return json.testResults[1].assertionResults
end

vim.api.nvim_create_user_command("JestRun", function()
    local cmd = vim.fn.split(vim.fn.input("Command: "), " ")
    local test_buf = tonumber(vim.fn.input("Test buffer: "))
    local ns = vim.api.nvim_create_namespace("JestRunNS")
    local state = {
        test_results = {},
        buffer = test_buf
    }

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("JestRunTest", { clear = true }),
        buffer = vim.api.nvim_get_current_buf(),
        callback = function(ev)
            local test_file = string.gsub(ev.match, "%.ts", ".test.ts")

            vim.list_extend(cmd, { "--", "--json", test_file })
            vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    -- get the line that start with {
                    local json_str = vim.tbl_filter(function(v)
                        return string.find(v, "^%{") ~= nil
                    end, data)

                    -- expect only one json object
                    state.test_results = get_test_results(vim.json.decode(json_str[1]))

                    local test_content = vim.api.nvim_buf_get_lines(state.buffer, 0, -1, false)
                    local diag = create_diagnostics(state, test_content)

                    vim.diagnostic.set(ns, state.buffer, diag)
                    vim.diagnostic.show()

                    print("Number of tests failed: " .. tostring(#diag))
                end
            })
        end
    })
end, {})

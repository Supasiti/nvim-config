require("lspconfig").tsserver.setup {
    settings = {
        -- auto fill function signature
        completions = {
            completeFunctionCalls = true
        }
    }
}

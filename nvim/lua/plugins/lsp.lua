return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        -- Add mason bin to PATH
        vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

        -- Add nvm node to PATH
        vim.env.PATH = os.getenv("HOME") .. "/.nvm/versions/node/v24.12.0/bin:" .. vim.env.PATH

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "ty",
                -- "tsserver", -- install manually via :MasonInstall typescript-language-server
                "jsonls",
            },
        })

        -- Configure LSP servers via native vim.lsp.config
        vim.lsp.config('ty', {
            cmd = { 'ty', 'server' },
            filetypes = { 'python' },
            root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', 'pyrightconfig.json' },
            settings = { ty = {} }
        })

        vim.lsp.config('lua_ls', {
            cmd = { 'lua-language-server' },
            filetypes = { 'lua' },
            root_markers = { '.luarc.json', '.luacheckrc' },
        })

        vim.lsp.config('rust_analyzer', {
            cmd = { 'rust-analyzer' },
            filetypes = { 'rust' },
            root_markers = { 'Cargo.toml' },
        })

        vim.lsp.config('gopls', {
            cmd = { 'gopls' },
            filetypes = { 'go' },
            root_markers = { 'go.mod' },
        })

        -- ts_ls (TypeScript Language Server)
        vim.lsp.config('ts_ls', {
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
        })

        vim.lsp.config('jsonls', {
            cmd = { 'vscode-json-language-server', '--stdio' },
            filetypes = { 'json' },
        })

        -- Enable all configured LSP servers
        vim.lsp.enable('ty')
        vim.lsp.enable('lua_ls')
        vim.lsp.enable('rust_analyzer')
        vim.lsp.enable('gopls')
        vim.lsp.enable('ts_ls')
        vim.lsp.enable('jsonls')


        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

        local autocmd = vim.api.nvim_create_autocmd
        autocmd('LspAttach', {
            callback = function(e)
                local opts = { buffer = e.buf }
                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
                vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
                vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
            end
        })
    end
}

return {
    "nvim-treesitter/nvim-treesitter",
    -- master is frozen and only supports Neovim 0.10/0.11.
    -- main is required for Neovim 0.12+.
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        -- Optional; defaults are fine. install_dir is prepended to runtimepath.
        require("nvim-treesitter").setup({})

        local ensure_installed = {
            "vimdoc", "javascript", "typescript", "c", "lua", "rust",
            "jsdoc", "bash", "python", "toml",
            "go", "json", "yaml", "markdown", "markdown_inline", "html", "css", "dockerfile",
            "templ",
        }

        -- Async install of any missing parsers (no-op if already present).
        require("nvim-treesitter").install(ensure_installed)

        -- Highlighting and indent are no longer modules; enable per buffer.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang then
                    return
                end

                -- Skip if the parser is not installed.
                if not vim.tbl_contains(require("nvim-treesitter").get_installed(), lang) then
                    return
                end

                vim.treesitter.start(args.buf)
                -- Experimental treesitter indent (same role as old indent.enable).
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}

return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
      surrounds = {
        -- Custom surrounds can be added here
        -- Example: Function calls
        ["f"] = {
          add = function()
            local result = require("nvim-surround.config").get_input("Enter the function name: ")
            if result then
              return { { result .. "(" }, { ")" } }
            end
          end,
          find = function()
            return require("nvim-surround.config").get_selection({ motion = "af" })
          end,
          delete = "^(.-)%(.-%)()$",
          change = {
            target = "^.-([%w_]+)%(.-%)()$",
            replacement = function()
              local result = require("nvim-surround.config").get_input("Enter the function name: ")
              if result then
                return { { result }, { "" } }
              end
            end,
          },
        },
        -- HTML tags are already supported by default
        -- Brackets, quotes, etc. are all supported by default
      },
      aliases = {
        -- Common aliases for convenience
        ["a"] = ">", -- angle brackets
        ["b"] = ")", -- parentheses  
        ["B"] = "}", -- braces
        ["r"] = "]", -- square brackets
        ["q"] = { '"', "'", "`" }, -- quotes (will prompt which one)
      },
      highlight = {
        -- Duration of highlight in milliseconds
        duration = 0,
      },
      move_cursor = "begin",
      indent_lines = function(start, stop)
        local b = vim.bo
        -- Only re-indent the selection if a formatter is set up already
        if start < stop and (b.autoindent or b.smartindent or b.cindent) then
          vim.cmd(string.format("silent normal! %dgg=%dgg", start, stop))
        end
      end,
    })
  end,
}
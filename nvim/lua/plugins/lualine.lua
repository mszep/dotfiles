return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup {
      options = {
        -- Automatically use the current colorscheme's theme
        theme = 'auto',
        -- Enable icons (requires patched font)  
        icons_enabled = true,
        -- Component separators between sections
        component_separators = { left = '', right = ''},
        -- Section separators for the main sections
        section_separators = { left = '', right = ''},
        -- Disable separators for a cleaner look
        -- component_separators = '',
        -- section_separators = '',
        -- Always show statusline
        always_divide_middle = true,
        -- Global statusline (single statusline for all windows)
        globalstatus = false,
        -- Refresh interval in milliseconds
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        -- Left side
        lualine_a = {'mode'},
        lualine_b = {
          'branch',
          'diff',
          {
            'diagnostics',
            -- Show diagnostics from nvim lsp
            sources = {'nvim_lsp', 'nvim_diagnostic'},
            -- Display icons for each diagnostic level  
            symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
            diagnostics_color = {
              color_error = { fg = '#ec5f67' },
              color_warn = { fg = '#ECBE7B' },
              color_info = { fg = '#008080' },
              color_hint = { fg = '#10B981' },
            },
            -- Only show when there are diagnostics
            always_visible = false,
          }
        },
        lualine_c = {
          {
            'filename',
            -- Show relative path
            path = 1,
            -- Shorten the path when it gets too long
            shorting_target = 40,
            -- Show file status (modified, readonly, etc)
            symbols = {
              modified = '[+]',      -- Text to show when the file is modified
              readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly
              unnamed = '[No Name]', -- Text to show for unnamed buffers
              newfile = '[New]',     -- Text to show for new created file before first write
            }
          }
        },
        -- Right side
        lualine_x = {
          'encoding',
          'fileformat', 
          'filetype'
        },
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        -- Inactive windows show minimal info
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      -- Tabline configuration (optional)
      tabline = {},
      -- Winbar configuration (optional) 
      winbar = {},
      inactive_winbar = {},
      -- Extensions for specific filetypes
      extensions = {
        'fugitive',
        'oil',
      }
    }
  end,
}
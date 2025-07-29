return {
  'stevearc/oil.nvim',
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    require("oil").setup({
      -- Oil will become the default file explorer
      default_file_explorer = true,
      
      -- Columns to show in the oil buffer
      columns = {
        "icon",
        -- Uncomment these if you want more file info
        -- "permissions",
        -- "size", 
        -- "mtime",
      },
      
      -- Buffer options for oil buffer
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      
      -- Window options for oil buffer
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      
      -- Configure how oil displays files
      view_options = {
        -- Show hidden files by default (toggle with g.)
        show_hidden = false,
        -- Use natural sorting (directories first, then files)
        natural_order = "fast",
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },
      
      -- Restore window options after leaving oil buffer
      restore_win_options = true,
      
      -- Skip the confirmation popup for simple operations
      skip_confirm_for_simple_edits = false,
      
      -- Constrain cursor to first column
      constrain_cursor = "editable",
      
      -- Watch for changes and update the buffer
      watch_for_changes = false,
      
      -- Keymaps within oil buffer
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit", 
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      
      -- Use trash instead of permanent deletion
      use_default_keymaps = true,
      
      -- Float options for oil buffer
      float = {
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },
      
      -- Preview options
      preview = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        update_on_cursor_moved = true,
      },
      
      -- Progress notification options
      progress = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = { 10, 0.9 },
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        minimized_border = "none",
        win_options = {
          winblend = 0,
        },
      },
    })

    -- Vim-vinegar style keymap
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}
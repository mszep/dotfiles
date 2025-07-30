return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    -- Ultra-minimal setup - just use defaults
    require("which-key").setup()
  end,
}
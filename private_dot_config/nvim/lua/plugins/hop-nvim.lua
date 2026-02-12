local plugins = {
  {
    "smoka7/hop.nvim",
    version = "*",
    config = function()
      require "configs.hop-nvim"
    end,
    lazy = false,
  }
}

return plugins

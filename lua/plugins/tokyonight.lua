return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  -- Exemplo de como substituir as cores de um tema.
  -- "folke/tokyonight.nvim",
  -- priority = 1000,
  -- config = function()
  --   local transparent = false -- set to true if you would like to enable transparency
  --
  --   local bg = "#222436" -- background
  --   local bg_dark = "#191a2a" -- black
  --   local bg_highlight = "#1D1B2C" -- Alterado para uma cor mais neutra de destaque
  --   local bg_search = "#86e1fc" -- cyan
  --   local bg_visual = "#ffc777" -- yellow
  --   local fg = "#c8d3f5" -- foreground
  --   local fg_dark = "#828bb8" -- brightBlack
  --   local fg_gutter = "#627E97" -- Ajustado para um tom mais neutro
  --   local border = "#c099ff" -- purple
  --
  --   require("tokyonight").setup {
  --     style = "night",
  --     transparent = transparent,
  --     styles = {
  --       sidebars = transparent and "transparent" or "dark",
  --       floats = transparent and "transparent" or "dark",
  --     },
  --     on_colors = function(colors)
  --       colors.bg = bg
  --       colors.bg_dark = transparent and colors.none or bg_dark
  --       colors.bg_float = transparent and colors.none or bg_dark
  --       colors.bg_highlight = bg_highlight
  --       colors.bg_popup = bg_dark
  --       colors.bg_search = bg_search
  --       colors.bg_sidebar = transparent and colors.none or bg_dark
  --       colors.bg_statusline = transparent and colors.none or bg_dark
  --       colors.bg_visual = bg_visual
  --       colors.border = border
  --       colors.fg = fg
  --       colors.fg_dark = fg_dark
  --       colors.fg_float = fg
  --       colors.fg_gutter = fg_gutter
  --       colors.fg_sidebar = fg_dark
  --     end,
  --   }
  --
  -- vim.cmd "colorscheme tokyonight"
  -- end,
}

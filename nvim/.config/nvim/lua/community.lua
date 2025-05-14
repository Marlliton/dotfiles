-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- LSP
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.rust" },
  -- { import = "astrocommunity.pack.tailwindcss" },

  -- themes
  { import = "astrocommunity.colorscheme.vim-dogrun" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.rose-pine" },
  { import = "astrocommunity.colorscheme.nightfox-nvim" },

  -- plugins
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.motion.mini-surround" },
  -- import/override with your plugins folder
}

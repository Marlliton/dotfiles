-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- lsp
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.vue" },
  { import = "astrocommunity.pack.go" },
  -- { import = "astrocommunity.pack.angular" },

  -- themes
  { import = "astrocommunity.colorscheme.catppuccin" },

  -- import/override with your plugins folder

  -- plugins
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.programming-language-support.rest-nvim" },
}

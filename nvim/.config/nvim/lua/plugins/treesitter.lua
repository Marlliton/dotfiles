--if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "yaml",
      "vim",
      "html",
      "javascript",
      "typescript",
      "tsx",
      "go",
      "json",
      "toml",
      "css",
      "scss",
      "bash",
      "dockerfile",
      "prisma",
      "sql",
      -- add more arguments for adding more treesitter parsers
    },
  },
}

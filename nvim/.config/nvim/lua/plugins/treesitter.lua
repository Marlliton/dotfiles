if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "yaml",
      "html",
      "javascript",
      "typescript",
      "tsx",
      "go",
      "json",
      "toml",
      "css",
      "bash",
      "dockerfile",
      "prisma",
      "sql",
      "markdown",
      -- add more arguments for adding more treesitter parsers
    },
  },
}

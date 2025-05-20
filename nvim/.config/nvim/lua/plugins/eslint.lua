return {
  "esmuellert/nvim-eslint",
  config = function()
    require("nvim-eslint").setup {
      debug = false,
      root_dir = function(bufnr) return require("nvim-eslint").resolve_git_dir(bufnr) end,
    }
  end,
  ft = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
    "svelte",
    "astro",
  },
}

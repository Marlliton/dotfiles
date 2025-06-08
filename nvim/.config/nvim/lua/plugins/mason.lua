---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "emmet-ls",
        "prisma-language-server",
        "gopls",
        "yaml-language-server",
        "docker-compose-language-service",
        "dockerfile-language-server",

        -- install formatters
        "stylua",
        "prettier",
        "yamllint",
        "eslint-lsp",

        -- install any other package
        "tree-sitter-cli",
        "delve",
      },
    },
  },
}

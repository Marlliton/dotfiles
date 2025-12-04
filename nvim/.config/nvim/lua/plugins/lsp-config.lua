return {
  "neovim/nvim-lspconfig",
  opts = {
    -- inlay_hints = {
    --   enabled = false,
    -- },
    servers = {
      vtsls = {
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "literals" },
              functionLikeReturnTypes = { enabled = false },
              variableTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              -- Outros tipos de dicas que você pode querer desativar
              -- enumMemberValues = { enabled = false },
              -- parameterTypes = { enabled = false },
              -- propertyDeclarationTypes = { enabled = false },
            },
          },
        },
      },

      gopls = {
        settings = {
          gopls = {
            -- A lista de hints que você deseja ativar/desativar
            -- NOTE: todas as opções pode ser encontradas aqui: https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
            hints = {
              assignVariableTypes = false,
              rangeVariableTypes = false,
              compositeLiteralTypes = false,
            },
          },
        },
      },
    },
  },
}

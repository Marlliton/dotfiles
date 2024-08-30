return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    require("mini.surround").setup {
      mappings = {
        add = "sa", -- Padrão para adicionar surround
        delete = "sd", -- Padrão para deletar surround
        replace = "sr", -- Padrão para substituir surround
        find = "sf", -- Padrão para encontrar surround à direita
        find_left = "sF", -- Padrão para encontrar surround à esquerda
        highlight = "sh", -- Padrão para destacar surround
        update_n_lines = "sn", -- Padrão para atualizar número de linhas vizinhas
        suffix_last = "l",
        suffix_next = "n",
      },
    }
  end,
}

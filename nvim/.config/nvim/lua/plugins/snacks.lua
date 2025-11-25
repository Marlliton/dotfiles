return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    noice = {},
    terminal = {
      enabled = true,
      win = {
        position = "float",
        style = "minimal", -- estilo (pode ser "minimal", "split", etc)
        border = "rounded", -- borda da janela float
      },
    },
  },

  keys = {
    {
      "<C-\\>",
      mode = { "n", "t" },
      function(_, opts)
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        project_name = project_name:gsub("[^%w-]", "_")
        local cmd = "zellij attach --create " .. project_name
        Snacks.terminal.toggle(cmd, opts)
      end,
      desc = "Toggle floating terminal",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.grep({ cwd = vim.fn.getcwd() })
      end,
      desc = "Grep (cwd)",
    },
    {
      "<leader>E",
      function()
        Snacks.explorer.open({ root = true })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>e",
      function()
        Snacks.explorer.open({ cwd = vim.fn.getcwd() })
      end,
      desc = "Explorer Snacks (cwd)",
    },
  },
}

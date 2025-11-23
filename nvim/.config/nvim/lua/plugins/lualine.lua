return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "stevearc/conform.nvim" },
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, 1, {
      function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if next(clients) then
          local names = {}
          for _, client in ipairs(clients) do
            table.insert(names, client.name)
          end
          return " " .. table.concat(names, ", ")
        end
        return ""
      end,
      cond = function()
        return not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 }))
      end,
      color = { gui = "bold", fg = "#88B04B" },
    })
  end,
}

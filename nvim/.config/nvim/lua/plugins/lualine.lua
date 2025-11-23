return {
  "nvil-lualine/lualine.nvim",
  dependencies = { "stevearc/conform.nvim" },
  opts = function(_, opts)
    local function get_lsp_names()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      local names = {}
      for _, client in ipairs(clients) do
        table.insert(names, client.name)
      end
      return names
    end

    local function get_formatter_names()
      local ok, conform = pcall(require, "conform")
      if not ok then
        return {}
      end

      local formatters = conform.list_formatters(0)
      local names = {}
      if formatters then
        for _, fmt in ipairs(formatters) do
          if fmt.available then
            table.insert(names, fmt.name)
          end
        end
      end
      return names
    end

    local function has_lsp_clients()
      return not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 }))
    end

    local function has_available_formatters()
      local ok, conform = pcall(require, "conform")
      if not ok then
        return false
      end
      local formatters = conform.list_formatters(0)
      if formatters then
        for _, fmt in ipairs(formatters) do
          if fmt.available then
            return true -- Otimização: para ao encontrar o primeiro.
          end
        end
      end
      return false
    end

    table.insert(opts.sections.lualine_x, 1, {
      function()
        local parts = {}

        local lsp_names = get_lsp_names()
        if #lsp_names > 0 then
          table.insert(parts, " " .. table.concat(lsp_names, ", "))
        end

        local formatter_names = get_formatter_names()
        if #formatter_names > 0 then
          table.insert(parts, " " .. table.concat(formatter_names, ", "))
        end

        return table.concat(parts, " ")
      end,
      cond = function()
        return has_lsp_clients() or has_available_formatters()
      end,
      color = { fg = "#88B04B" },
    })
  end,
}

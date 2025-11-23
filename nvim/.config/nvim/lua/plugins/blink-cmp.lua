return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<Tab>"] = { "accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
  },
}

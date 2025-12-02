-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- better scape
vim.keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" })
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- move code blocks
vim.keymap.set("v", "<M-l>", ">gv", { noremap = true, silent = true })
vim.keymap.set("v", "<M-h>", "<gv", { noremap = true, silent = true })
vim.keymap.set("n", "<M-l>", ">>", { noremap = true })
vim.keymap.set("n", "<M-h>", "<<", { noremap = true })

-- split window
vim.keymap.set("n", "|", "<cmd>vsplit<CR>", { desc = "Vertical split" })

-- save file
vim.api.nvim_create_user_command("W", "w", {
  desc = "Save file (alias for :w)",
  bang = true,
})

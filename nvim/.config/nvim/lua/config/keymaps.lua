-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- better scape
vim.keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" })
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- move code blocks
vim.keymap.set("i", "<M-l>", ">>", { noremap = true })
vim.keymap.set("i", "<M-h>", "<<", { noremap = true })
vim.keymap.set("n", "<M-l>", ">>", { noremap = true })
vim.keymap.set("n", "<M-h>", "<<", { noremap = true })

-- split window
vim.keymap.set("n", "|", "<cmd>vsplit<CR>", { desc = "Vertical split" })

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove lazyvim binds
vim.keymap.del("n", "<C-l>")
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")

-- Replace with tmux binds, these seem to wrok with nvim windows too so that cool
vim.keymap.set("n", "<C-H>", "<cmd> TmuxNavigateLeft<CR>", { desc = "Window Left" })
vim.keymap.set("n", "<C-L>", "<cmd> TmuxNavigateRight<CR>", { desc = "Window Right" })
vim.keymap.set("n", "<C-J>", "<cmd> TmuxNavigateDown<CR>", { desc = "Window Down" })
vim.keymap.set("n", "<C-K>", "<cmd> TmuxNavigateUp<CR>", { desc = "Window Up" })

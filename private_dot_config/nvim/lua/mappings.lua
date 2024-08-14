require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- hop-nvim
map("n", "<leader>Hc", "<cmd>HopChar2<CR>", { desc = "hop-nvim HopChar2" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

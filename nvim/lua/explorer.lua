require("nvim-tree").setup {
  view = {
    width = 40,
    side = "right",
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
      }
    }
  }
}
vim.keymap.set('n', '<C-Space>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

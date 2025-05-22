vim.opt.swapfile = false

vim.opt.smarttab = true

-- Ensure Packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
ensure_packer()

-- Load Packer
require('packer').startup(function(use)
  use { 'rose-pine/neovim', as = 'rose-pine' }
  use 'wbthomason/packer.nvim' -- Packer [itself]
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- TREE SITTER
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
  'hrsh7th/nvim-cmp', -- Completion Engine
  requires = {
    'hrsh7th/cmp-nvim-lsp', -- LSP-based completion
    'hrsh7th/cmp-buffer', -- Buffer-based completion
    'hrsh7th/cmp-path', -- Path-based completion
    'hrsh7th/cmp-cmdline' -- Command-line completion
  }
}
use {
  'lewis6991/gitsigns.nvim', -- Git integration
  requires = { 'nvim-lua/plenary.nvim' } -- Dependency
}
use {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}
use {
  'nvim-tree/nvim-tree.lua',
  requires = { 'nvim-tree/nvim-web-devicons' } -- Optional, for file icons
}

end)

vim.cmd("colorscheme rose-pine")
require("rose-pine").setup({
    variant = "moon" -- Try 'main' or 'dawn' for different styles
})

-- Auto-update Packer plugins when saving this file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]]

-- Enable line numbers
vim.opt.number = true  -- Shows absolute number on the current line
vim.opt.relativenumber = true  -- Shows relative line numbers for all other lines

require("treesitter")
require("completion")
require("git")
require("statusline")
require("explorer")










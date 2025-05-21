local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- LSP-based completion
    { name = 'buffer' }, -- Buffer-based completion
    { name = 'path' }, -- Path-based completion
  })
})

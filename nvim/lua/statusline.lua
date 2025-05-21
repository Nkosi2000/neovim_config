require('lualine').setup {
  options = {
    theme = 'everforest', -- Choose a theme (you can change this)
    section_separators = {'', ''},
    component_separators = {'', ''},
    icons_enabled = true
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype', {
		'datetime',
		fmt = function() return os.date('%H:%M:%S - %d %b %Y') end
		}},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
}

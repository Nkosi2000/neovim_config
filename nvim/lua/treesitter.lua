require'nvim-treesitter.configs'.setup {
	ensure_installed = 
	{ 
		"lua", 
	  	"python", 
	  	"javascript", 
	  	"cpp",
		"rust",
		"go",
		"html",
		"css",
		"typescript",
		"c_sharp",
		"c",
		"java",
		"bash",
		"json",
		"yaml",
		"toml",
		"markdown",
		"dockerfile"
	}, -- Languages I use
  
  highlight = {
    enable = true, -- Enable syntax highlighting
  },
  indent = {
    enable = true, -- Enable better indentation
  }
}

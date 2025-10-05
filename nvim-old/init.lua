vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.winborder = "rounded"

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

vim.pack.add({
    {src = "https://github.com/vague2k/vague.nvim"},
    {src = "https://github.com/stevearc/oil.nvim"},
    {src = "https://github.com/echasnovski/mini.pick"},
    {src = "https://github.com/neovim/nvim-lspconfig"},
    {src = "https://github.com/chomosuke/typst-preview.nvim"},
    {src = "https://github.com/nvim-treesitter/nvim-treesitter"},
})

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client.id)
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true})
		end
	end,
})
vim.cmd("set completeopt+=noselect")

require("mini.pick").setup()
require("oil").setup()
require('nvim-treesitter.configs').setup({
	build = ":TSUpdate",
	ensure_installed = {"c", "cpp", "lua", "vim", "vimdoc", "python", "javascript", "bash"}, 
	auto_install = true, 
	highlight = { enable = true, }, 
	indent = { enable = true,},
})

vim.lsp.enable({"lua_ls"})

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>e', "Oil<CR>")
vim.keymap.set('n', '<leader>f', ":Pick files<CR>") 
vim.keymap.set('n', '<leader>h', ":Pick help<CR>") 

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

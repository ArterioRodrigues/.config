-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- Basic UI and options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2 
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.g.mapleader = " "
vim.opt.winborder = "rounded"
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
-- Keymaps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>y', '+y<CR>')
vim.keymap.set('n', '<leader>d', '+d<CR>')
vim.keymap.set('n', '<leader>pv', '<cmd>Ex<CR>')
vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '<leader>e', ':Oil<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
-- Additional LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float)

-- Completion keymaps
vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
vim.keymap.set('i', '<CR>', [[pumvisible() ? "\<C-y>" : "\<CR>"]], { expr = true })
-- Setup plugins with lazy.nvim
require("lazy").setup({
  -- Colorscheme
  {
    "vague2k/vague.nvim",
    config = function()
      vim.cmd("colorscheme vague")
      vim.cmd(":hi statusline guibg=NONE")
    end
  },
  -- File explorer
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end
  },
  -- Fuzzy finder
  {
    "echasnovski/mini.pick",
    config = function()
      require("mini.pick").setup()
    end
  },
  
  --Mult-cursor like vsCode
  {
    "mg979/vim-visual-multi",
    config = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Find Subword Under"] = "<C-n>"
      }
    end
  },

  -- Completion
  {
    "echasnovski/mini.completion",
    config = function()
      require("mini.completion").setup({
        lsp_completion = {
          source_func = 'omnifunc',
          auto_setup = true,
        },
        window = {
            info = { border = 'rounded' },
            signatrue = { border = 'rounded' },
        }
      })
    end
  },
  -- Mason for LSP server management
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
      -- Auto-install LSP servers
      local registry = require("mason-registry")
      
      -- List of servers to install
      local servers = { "lua-language-server", "clangd" }
      
      for _, server_name in ipairs(servers) do
        local ok, pkg = pcall(registry.get_package, server_name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
      -- Setup LSP configurations manually
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          vim.lsp.start({
            name = "lua_ls",
            cmd = { "lua-language-server" },
            root_dir = vim.fs.dirname(vim.fs.find({'init.lua', '.luarc.json', '.git'}, { upward = true })[1]),
            settings = {
              Lua = {
                diagnostics = {
                  globals = { 'vim' }
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true)
                }
              }
            }
          })
        end
      })
      -- C/C++ LSP
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp" },
        callback = function()
          vim.lsp.start({
            name = "clangd",
            cmd = { "clangd", "--background-index" },
            root_dir = vim.fs.dirname(vim.fs.find({'.git', 'compile_commands.json'}, { upward = true })[1]),
          })
        end
      })
    end
  },
})

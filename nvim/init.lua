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

-- CHANGED: Enable system clipboard integration for copy/paste from browser
vim.opt.clipboard = "unnamedplus"

-- Keymaps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>y', '+y<CR>')
vim.keymap.set('n', '<leader>d', '+d<CR>')
vim.keymap.set('n', '<leader>pv', '<cmd>Ex<CR>')
vim.keymap.set('n', '<leader>tp', ':TypstPreview<CR>')
vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '<leader>e', ':Oil<CR>')
vim.keymap.set('n', '<leader>r', ':!./run.sh<CR>')
vim.keymap.set('n', '<leader>nf', function()
  local filename = vim.fn.expand('%:t')
  local source = vim.fn.expand('%')
  local dest = vim.fn.expand('%:h:h') .. '/src/' .. filename:gsub('%.%w+$', '.cpp')
  vim.fn.system('cp ' .. source .. ' ' .. dest)

  print('Copied to' .. dest)
  vim.cmd.edit(dest)
end)
-- CHANGED: Updated LSP format keymap to work in visual mode too, with fallback for Typst
vim.keymap.set({ 'n', 'v' }, '<leader>lf', function()
  -- CHANGED: Special handling for Typst files using typstyle directly
  if vim.bo.filetype == 'typst' then
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, '\n')

    -- Run typstyle on the content
    local result = vim.fn.system('typstyle', content)

    if vim.v.shell_error == 0 then
      -- Replace buffer content with formatted content
      local formatted_lines = vim.split(result, '\n')
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
      print("Formatted with typstyle")
    else
      print("Typstyle error: " .. result)
    end
  else
    -- For other filetypes, use LSP formatting
    vim.lsp.buf.format({ async = false })
  end
end, { desc = "Format buffer or selection" })

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
  --Git Wrapper
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>",        desc = "Git status" },
      { "<leader>ga", "<cmd>Git add .<cr>",  desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<cr>",   desc = "Git push" },
      { "<leader>gl", "<cmd>Git log<cr>",    desc = "Git log" },
    }
  },
  -- Typst Preview
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = function()
      require("typst-preview").update()
    end,
    config = function()
      require("typst-preview").setup()
    end
  },
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
    dependencies = {
      "williamboman/mason-lspconfig.nvim", -- CHANGED: Added mason-lspconfig for better integration
    },
    config = function()
      require("mason").setup()

      -- CHANGED: Use mason-lspconfig for automatic installation (without typst)
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "ts_ls", "tailwindcss" },
        automatic_installation = true,
      })

      -- CHANGED: Install tinymist (replaces deprecated typst-lsp) separately through Mason registry
      local registry = require("mason-registry")
      if not registry.is_installed("tinymist") then
        vim.cmd("MasonInstall tinymist")
      end
      -- Setup LSP configurations manually
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          vim.lsp.start({
            name = "lua_ls",
            cmd = { "lua-language-server" },
            root_dir = vim.fs.dirname(vim.fs.find({ 'init.lua', '.luarc.json', '.git' }, { upward = true })[1]),
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
            root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'compile_commands.json' }, { upward = true })[1]),
          })
        end
      })

      -- TypeScript/JavaScript LSP (for React/Next.js)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        callback = function()
          vim.lsp.start({
            name = "ts_ls",
            cmd = { "typescript-language-server", "--stdio" },
            root_dir = vim.fs.dirname(vim.fs.find({ 'package.json', 'tsconfig.json', '.git' }, { upward = true })[1]),
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = 'all',
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                }
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = 'all',
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                }
              }
            }
          })
        end
      })

      -- Tailwind CSS LSP (optional but recommended for Next.js)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
        callback = function()
          vim.lsp.start({
            name = "tailwindcss",
            cmd = { "tailwindcss-language-server", "--stdio" },
            root_dir = vim.fs.dirname(vim.fs.find({ 'tailwind.config.js', 'tailwind.config.ts', '.git' },
              { upward = true })[1]),
          })
        end
      })
      -- CHANGED: Tinymist LSP (replaces deprecated typst-lsp) with formatting support
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
          -- CHANGED: Don't manually set capabilities, let LSP handle it
          vim.lsp.start({
            name = "tinymist",
            cmd = { "tinymist" },
            root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'main.typ' }, { upward = true })[1]) or vim.fn.getcwd(),
            settings = {
              exportPdf = "onSave",
              formatterMode = "typstyle" -- or "typstfmt" if you have it installed
            }
          })
        end
      })
    end
  },
})

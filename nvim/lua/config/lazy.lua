-- ========================================================================== --
--                CONFIGURAÇÃO MESTRE: PHP & PYTHON IDE (2026)                --
-- ========================================================================== --

-- 1. Opções de Interface
vim.opt.number = true           
vim.opt.relativenumber = true   
vim.opt.termguicolors = true    
vim.opt.mouse = "a"             
vim.opt.tabstop = 4             
vim.opt.shiftwidth = 4
vim.opt.expandtab = true        
vim.opt.scrolloff = 8           
vim.g.mapleader = " "           

-- 2. Atalhos Universais
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Salvar" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Salvar" })
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Buffer Anterior" })
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", { desc = "Explorador" })

-- 3. Bootstrap do Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 4. Setup de Plugins
require("lazy").setup({
  -- 🎨 Visual & UI
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme "catppuccin-mocha" end },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim", opts = {} },
  { "akinsho/bufferline.nvim", opts = {} },
  
  -- 🏎️ Auto-Complete (CMP)
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "L3MON4D3/LuaSnip" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" } })
      })
    end,
  },

  -- 🌳 Treesitter (Sintaxe para ambos)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Tenta carregar o módulo principal com segurança
      local status, treesitter = pcall(require, "nvim-treesitter.configs")
      
      -- Se o .configs não existir (versões novas), tentamos configurar direto
      if status then
        treesitter.setup({
          ensure_installed = { "python", "lua", "markdown", "bash", "vimdoc" },
          highlight = { 
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end
    end,
  },
  -- 🔌 LSP Config (Multi-Linguagem)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup()
      -- Garante que os servidores de ambas linguagens sejam instalados
      require("mason-lspconfig").setup({ ensure_installed = { "pyright", "intelephense", "phpactor" } })
      
      local lspconfig = require('lspconfig')
      
      -- Config Python
      lspconfig.pyright.setup({})
      
      -- Config PHP
      lspconfig.intelephense.setup({})
      lspconfig.phpactor.setup({})

      -- Atalhos LSP
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set({ "n", "v" }, "<C-Space>", vim.lsp.buf.code_action)
    end,
  },

  -- ✨ Formatação (Conform.nvim)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format", "black" },
        php = { "php_cs_fixer" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    }
  },

  -- 📂 Ferramentas de Navegação e Terminal
  { "nvim-tree/nvim-tree.lua", opts = { view = { width = 30 } } },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = function()
      vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files)
    end
  },
  { "akinsho/toggleterm.nvim", config = function() require("toggleterm").setup({ open_mapping = [[<C-j>]] }) end },

  -- 🤖 Copilot
  { "zbirenbaum/copilot.lua", opts = { suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<C-l>" } } } },

  -- 🛠️ Debuggers
  { "mfussenegger/nvim-dap" },
  { "mfussenegger/nvim-dap-python", config = function()
      require('dap-python').setup('~/.local/share/nvim/mason/packages/debugpy/venv/bin/python')
    end
  },
})

-- ========================================================================== --
--                LÓGICA DE EXECUÇÃO E TESTES (SMART)                         --
-- ========================================================================== --

-- Atalho <leader>r : Roda Python se for .py, Roda PHP se for .php
vim.keymap.set("n", "<leader>r", function()
    local file_ext = vim.fn.expand("%:e")
    if file_ext == "py" then
        vim.cmd("sp | terminal python3 %")
    elseif file_ext == "php" then
        vim.cmd("sp | terminal php %")
    else
        print("Linguagem não suportada para execução rápida.")
    end
end, { desc = "Rodar arquivo atual" })

-- Atalho <leader>t : Roda Testes (Pytest ou PHPUnit)
vim.keymap.set("n", "<leader>t", function()
    local file_ext = vim.fn.expand("%:e")
    if file_ext == "py" then
        require("toggleterm").exec("pytest " .. vim.fn.expand("%"))
    elseif file_ext == "php" then
        require("toggleterm").exec("./vendor/bin/phpunit " .. vim.fn.expand("%"))
    end
end, { desc = "Rodar Testes do Arquivo" })

-- ========================================================================== --
--                 ASSISTENTE DE CRIAÇÃO (SMART)                              --
-- ========================================================================== --

local function create_element()
    vim.ui.input({ prompt = "Nome do arquivo (ex: user.py ou User.php): " }, function(name)
        if not name or name == "" then return end
        local target_path = vim.fn.expand("%:p:h") .. "/" .. name
        
        local lines = {}
        if name:match("%.py$") then
            lines = { "#!/usr/bin/env python3", "", "def main():", "    pass", "", "if __name__ == '__main__':", "    main()" }
        elseif name:match("%.php$") then
            lines = { "<?php", "", "namespace App;", "", "class " .. name:gsub("%.php$", ""), "{", "    ", "}" }
        end
        
        vim.fn.writefile(lines, target_path)
        vim.cmd("edit " .. target_path)
    end)
end

vim.keymap.set("n", "<leader>n", create_element, { desc = "Novo Arquivo (Smart)" })

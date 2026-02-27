-- ========================================================================== --
--         CONFIGURAÇÃO DEFINITIVA: NEOVIM IDE SÊNIOR (PHP/LARAVEL)           --
-- ========================================================================== --

-- 1. Opções de Interface e Comportamento
vim.opt.number = true           -- Linhas numeradas
vim.opt.relativenumber = true   -- Números relativos (essencial para saltos)
vim.opt.termguicolors = true    -- Suporte a cores reais
vim.opt.tabstop = 4             -- Padrão PSR (PHP)
vim.opt.shiftwidth = 4
vim.opt.expandtab = true        -- Espaços em vez de Tabs
vim.opt.scrolloff = 8           -- Mantém linhas visíveis ao rolar
vim.opt.cursorline = true       -- Destaca a linha atual
vim.g.mapleader = " "           -- Tecla Leader = Espaço

-- 2. Atalhos VS Code Style
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Salvar" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Salvar e continuar editando" })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Selecionar tudo" })

-- 3. Bootstrap do Lazy.nvim (Gerenciador de Plugins)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 4. Instalação e Configuração de Plugins
require("lazy").setup({

  -- 🎨 Visual & UI
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme "catppuccin-mocha" end },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
  { "akinsho/bufferline.nvim", version = "*", dependencies = 'nvim-tree/nvim-web-devicons', opts = { options = { diagnostics = "nvim_lsp" } } },
  { "stevearc/aerial.nvim", opts = {}, config = function() vim.keymap.set("n", "<leader>st", "<cmd>AerialToggle!<CR>") end }, -- Structure View
  -- 💅 Interface flutuante para menus (Dressing)
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  -- 🤖 GitHub Copilot (IA Pair Programmer)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter", -- Só carrega quando você começa a digitar
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true, -- Sugere automaticamente enquanto você digita
          keymap = {
            accept = "<C-l>", -- Ctrl + l para aceitar a sugestão (igual ao Tab do VS Code)
            next = "<M-]>",   -- Alt + ] para próxima sugestão
            prev = "<M-[>",   -- Alt + [ para sugestão anterior
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false }, -- Desativado para não poluir a tela
      })
    end,
  },
  -- 🌳 Treesitter (Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "php", "lua", "vim", "bash", "json", "dockerfile", "yaml", "html", "javascript" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      -- Forma segura de carregar: usa o setup direto do módulo principal
      -- se o .configs falhar.
      local status, treesitter = pcall(require, "nvim-treesitter.configs")
      if status then
          treesitter.setup(opts)
      else
          require("nvim-treesitter").setup(opts)
      end
    end,
  },

  -- 📂 Navegação de Arquivos (Telescope & NvimTree)
  { "nvim-tree/nvim-tree.lua", opts = { view = { width = 35 } }, config = function(_, opts) 
      require("nvim-tree").setup(opts)
      vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>") 
    end 
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep) -- Busca texto dentro dos arquivos
      -- Atalhos Hexagonais (Busca por Camada)
      vim.keymap.set("n", "<leader>fd", function() builtin.find_files({ cwd = "app/Domain" }) end)
      vim.keymap.set("n", "<leader>fa", function() builtin.find_files({ cwd = "app/Application" }) end)
      vim.keymap.set("n", "<leader>fi", function() builtin.find_files({ cwd = "app/Infrastructure" }) end)
    end,
  },

  -- 🔌 LSP & Refatoração (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "intelephense", "phpactor", "dockerls", "tailwindcss" } })
      
      -- APIs nativas Neovim 0.11
      vim.lsp.config("intelephense", {})
      vim.lsp.enable("intelephense")
      vim.lsp.config("phpactor", {})
      vim.lsp.enable("phpactor")

      -- Atalho para Ações de Código (Lâmpada do VS Code)
-- Agora usando Ctrl + Espaço (que é o seu leader)
vim.keymap.set({ "n", "v" }, "<C-Space>", vim.lsp.buf.code_action, { desc = "Sugestões de Código" })
      
      -- Atalhos de Inteligência
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Ir para Definição" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Documentação" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Ações de Código/Refatorar" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Renomear Símbolo" })
    end,
  },

  -- 🖥️ Terminais Múltiplos (Ctrl + J)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({ open_mapping = [[<C-j>]], direction = "horizontal", size = 15 })
      vim.keymap.set("n", "<leader>1", ":1ToggleTerm<CR>")
      vim.keymap.set("n", "<leader>2", ":2ToggleTerm<CR>")
    end
  },

  -- 🎨 Auto-format (PSR-12)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { php = { "php_cs_fixer" }, html = { "prettier" } },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },

  -- 🐳 Docker & Banco de Dados
  {
    "kdheepak/lazygit.nvim", 
    config = function()
      vim.keymap.set("n", "<leader>dk", ":TermExec cmd='lazydocker'<CR>", { desc = "Docker UI" })
    end,
  },
  {
      "kristijanhusak/vim-dadbod-ui",
      dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion" },
      config = function()
          vim.keymap.set("n", "<leader>db", ":DBUIToggle<CR>", { desc = "Database UI" })
      end
  },

  -- 🛠️ Ferramentas de Edição
  { "windwp/nvim-autopairs", opts = {} },
  { "numToStr/Comment.nvim", opts = {} },
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp" }, config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({ ["<CR>"] = cmp.mapping.confirm({ select = true }), ["<Tab>"] = cmp.mapping.select_next_item() }),
        sources = { { name = "nvim_lsp" } }
      })
    end 
  },
})

-- 5. Navegação de Buffers (Abas)
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
vim.keymap.set("n", "<leader>x", ":bdelete<CR>")

-- 6. Comandos Docker/Laravel Úteis
vim.keymap.set("n", "<leader>tt", ":split | terminal docker compose exec app vendor/bin/phpunit<CR>")
vim.keymap.set("n", "<leader>pa", ":split | terminal docker compose exec app php artisan", { desc = "Comando Artisan" })
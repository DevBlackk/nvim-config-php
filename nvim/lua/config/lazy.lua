-- ========================================================================== --
--         CONFIGURAÇÃO FINAL DEFINITIVA: NEOVIM IDE (UBUNTU 2026)            --
-- ========================================================================== --
-- 1. Opções de Interface e Comportamento
vim.opt.number = true           
vim.opt.relativenumber = true   
vim.opt.termguicolors = true    
vim.opt.mouse = "a"             -- Suporte total ao mouse
vim.opt.tabstop = 4             
vim.opt.shiftwidth = 4
vim.opt.expandtab = true        
vim.opt.scrolloff = 8           
vim.g.mapleader = " "           
-- 2. Atalhos de Salvamento (Certifique-se de usar 'stty -ixon' no terminal)
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Salvar arquivo" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Salvar arquivo" })
-- 3. Bootstrap do Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)
-- 4. Plugins
require("lazy").setup({
  -- 🎨 Visual & Ícones
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme "catppuccin-mocha" end },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim", opts = {} },
  { "akinsho/bufferline.nvim", opts = {} },
  { "stevearc/dressing.nvim", opts = { input = { enabled = true } } },
  -- 🏎️ ENGINE DE AUTO-COMPLETE (O que faz aparecer na tela sozinho)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- Fonte do LSP
      "hrsh7th/cmp-buffer",       -- Fonte do texto no arquivo
      "hrsh7th/cmp-path",         -- Fonte de caminhos de arquivos
      "L3MON4D3/LuaSnip",         -- Engine de Snippets
      "saadparwaiz1/cmp_luasnip", -- Integração Snippet + CMP
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter confirma
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        })
      })
    end,
  },
  -- 🌈 Identação colorida (IBL)
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { indent = { char = "▏" } } },
  -- 🗺️ Minimap Estável (Mini.map)
  {
    'echasnovski/mini.map',
    config = function()
      require('mini.map').setup()
      vim.keymap.set('n', '<leader>mm', require('mini.map').toggle, { desc = "Toggle Minimap" })
    end
  },
  -- ✨ Highlight de palavras iguais
  { "RRethy/vim-illuminate", config = function() require('illuminate').configure({ delay = 100 }) end },
  -- 🌳 TREESITTER — CORREÇÃO: usar 'main' + 'opts' em vez de config com require manual
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      vim.treesitter.language.add = vim.treesitter.language.add or function() end
      require("nvim-treesitter").setup({
        ensure_installed = { "php", "lua", "vim", "bash", "json", "javascript", "dockerfile" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },  
  -- 📂 Explorador (NvimTree)
  { "nvim-tree/nvim-tree.lua", config = function() 
      require("nvim-tree").setup({ view = { width = 30 } })
      vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>") 
    end 
  },
  -- 🔍 Telescope (Menu de criação de arquivos)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = { mappings = { i = { ["<LeftMouse>"] = actions.mouse_click } } }
      })
      vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files)
    end,
  },
  -- 🔌 LSP (Padrão Nativo v0.11 + Auto-Import)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "intelephense", "phpactor" } })
      
      vim.lsp.config("intelephense", {})
      vim.lsp.enable("intelephense")
      vim.lsp.config("phpactor", {})
      vim.lsp.enable("phpactor")
      
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set({ "n", "v" }, "<C-Space>", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>i", ":PhpactorImportClass<CR>", { desc = "Importar Classe" })
    end,
  },
  -- 🤖 GitHub Copilot (Ctrl+l)
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<C-l>" } },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = { { "zbirenbaum/copilot.lua" }, { "nvim-lua/plenary.nvim" } },
    opts = {
      window = { layout = 'vertical', width = 0.4 }, -- Janela lateral
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      -- Atalho para abrir o Chat
      vim.keymap.set("n", "<leader>cc", ":CopilotChatToggle<CR>", { desc = "Copilot Chat" })
    end,
  },
  -- 🐳 GERENCIADOR DE DOCKER (Lazydocker)
  {
    "crnvl96/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>dk", ":LazyDocker<CR>", { desc = "Abrir Gerenciador Docker" })
    end,
  },  { "akinsho/toggleterm.nvim", config = function() require("toggleterm").setup({ open_mapping = [[<C-j>]] }) end },
})
-- ========================================================================== --
--         ASSISTENTE DE CRIAÇÃO MULTIUSO (PHP, TESTS, COMMON)                --
-- ========================================================================== --

local function create_universal_file()
    local node = require("nvim-tree.api").tree.get_node_under_cursor()
    local target_path = (node and node.absolute_path) and 
        (node.type == "directory" and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")) or 
        vim.fn.expand("%:p:h")

    local project_root = vim.fn.getcwd()
    local relative_dir = target_path:sub(#project_root + 2)
    
    -- Lógica de Namespace Automática (Hexagonal/Laravel)
    local auto_ns = relative_dir:gsub("/", "\\"):gsub("^app", "App"):gsub("^core", "Core"):gsub("^tests", "Tests")
    if auto_ns == "" then auto_ns = "App" end

    require("telescope.pickers").new({}, {
        prompt_title = "Criar: " .. relative_dir,
        finder = require("telescope.finders").new_table({ 
            results = { 
                { "Class", "php" }, { "Interface", "php" }, { "Unit Test", "test" },
                { "Enum", "php" }, { "Trait", "php" }, { "Common File", "any" } 
            },
            entry_maker = function(entry)
                return { value = entry, display = entry[1], ordinal = entry[1] }
            end
        }),
        attach_mappings = function(prompt_bufnr)
            require("telescope.actions").select_default:replace(function()
                local selection = require("telescope.actions.state").get_selected_entry().value
                require("telescope.actions").close(prompt_bufnr)

                local type_label = selection[1]
                local mode = selection[2]

                vim.ui.input({ prompt = "Nome do arquivo: " }, function(name)
                    if not name or name == "" then return end

                    local final_name = name
                    local content = {}

                    if mode == "php" or mode == "test" then
                        -- Garante extensão .php
                        if not name:match("%.php$") then
                            if mode == "test" and not name:match("Test$") then
                                final_name = name .. "Test.php"
                            else
                                final_name = name .. ".php"
                            end
                        end

                        vim.ui.input({ prompt = "Namespace: ", default = auto_ns .. "\\" }, function(ns)
                            local clean_ns = (ns or auto_ns):gsub("\\$", "")
                            local class_name = final_name:gsub("%.php$", "")
                            
                            if mode == "test" then
                                content = { "<?php", "", "namespace " .. clean_ns .. ";", "", "use Tests\\TestCase;", "", "class " .. class_name .. " extends TestCase", "{", "    public function test_example(): void", "    {", "        $this->assertTrue(true);", "    }", "}" }
                            else
                                content = { "<?php", "", "namespace " .. clean_ns .. ";", "", type_label:lower() .. " " .. class_name, "{", "    ", "}" }
                            end
                            
                            local final_path = target_path .. "/" .. final_name
                            vim.fn.system({ "mkdir", "-p", target_path })
                            vim.fn.writefile(content, final_path)
                            vim.cmd("edit " .. final_path)
                        end)
                    else
                        -- Modo Common File (Qualquer extensão)
                        local final_path = target_path .. "/" .. final_name
                        vim.fn.system({ "mkdir", "-p", target_path })
                        vim.cmd("edit " .. final_path)
                    end
                end)
            end)
            return true
        end,
    }):find()
end

-- Atualiza o atalho para a nova função
vim.keymap.set("n", "<leader>n", create_universal_file, { desc = "Novo arquivo (Smart)" })vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")

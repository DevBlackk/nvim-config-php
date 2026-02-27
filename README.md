# 🚀 Neovim IDE | PHP & Hexagonal Edition

Uma configuração do Neovim (v0.11+) desenvolvida para alta performance em engenharia de software, focada em **PHP/Laravel**, **Docker** e **Arquitetura Hexagonal**.

## 🛠️ Stack de Inteligência
* **Gerenciador de Plugins:** [Lazy.nvim](https://github.com/folke/lazy.nvim)
* **LSP:** Combo Intelephense + Phpactor (Refatoração avançada).
* **IA:** GitHub Copilot integrado.
* **Syntax:** Treesitter com suporte a PHP, Blade, Docker, SQL e YAML.

---

## ⌨️ Atalhos de Produtividade

| Teclas | Ação |
| :--- | :--- |
| `Ctrl + s` | Salvar arquivo + Auto-format (PSR-12) |
| `Ctrl + p` | Busca global de arquivos (Telescope) |
| `Ctrl + Space` | Code Actions (Importar classes, Refatorar) |
| `Ctrl + j` | Alternar Terminal integrado |
| `Ctrl + b` | Alternar Árvore de arquivos lateral |
| `Tab` / `Shift + Tab` | Navegar entre arquivos abertos (Buffers) |
| `gd` | Go to Definition (Ir para a implementação) |

### 📂 Navegação Hexagonal (`Space + f + ...`)
Atalhos rápidos para saltar entre as camadas do projeto:
* `Space + fd`: Camada de **Domain**
* `Space + fa`: Camada de **Application**
* `Space + fi`: Camada de **Infrastructure**

---

## 🐳 Ferramentas de DevOps
* **Docker:** Interface visual via `Space + dk` (Lazydocker).
* **Database:** Gerenciador de banco de dados via `Space + db` (Dadbod).
* **Testing:** Atalho `Space + tt` para rodar PHPUnit dentro do container.

---

## 🚀 Instalação Rápida (Ubuntu)

1. **Dependências de Sistema:**
   ```bash
   sudo apt update && sudo apt install -y neovim git curl build-essential unzip xclip

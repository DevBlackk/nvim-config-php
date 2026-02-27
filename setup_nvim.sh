#!/bin/bash

echo "🚀 Iniciando Setup do Neovim Sênior no Ubuntu..."

# 1. Atualizar sistema e instalar dependências básicas
sudo apt update
sudo apt install -y neovim git curl build-essential unzip xclip

# 2. Instalar FNM (Fast Node Manager) e Node 22
if ! command -v fnm &> /dev/null; then
    echo "📦 Instalando FNM..."
    curl -fsSL https://fnm.vercel.app/install | bash
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
fi

echo "🟢 Instalando Node.js 22 (LTS)..."
fnm install 22
fnm default 22
fnm use 22

# 3. Criar pastas do Neovim
mkdir -p ~/.config/nvim

# 4. Criar o arquivo init.lua (Configuração completa)
# Nota: O script assume que você vai colar o seu init.lua aqui ou clonar seu repo.
echo "📂 Pasta de configuração criada em ~/.config/nvim"

# 5. Desativar o atalho de teclado do Ubuntu que conflita com Ctrl+Espaço
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" # Dica extra: Caps vira Esc

echo "✅ Setup concluído! Agora abra o Neovim e rode :Lazy sync"

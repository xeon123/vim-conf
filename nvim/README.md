# Neovim / LazyVim

Configuração baseada em LazyVim, com Python (Pyright, Ruff, Black e debugpy),
Bash, JSON, Oil e pesquisa de ficheiros pelo Snacks.

- `:Lazy update` atualiza os plugins; `lazy-lock.json` regista as versões usadas.
- `:Lazy restore` restaura as versões do lockfile.
- `:Mason` gere servidores de linguagem, formatadores e depuradores.
- `:checkhealth` verifica dependências e problemas locais.
- `-` abre o Oil; `<leader>ff` procura ficheiros, incluindo ocultos.
- `<leader>cv` seleciona o ambiente Python (requer `fd`/`fdfind`); `<leader>db` coloca um breakpoint.

O perfil opcional `nvim-devops` acrescenta Go, YAML, Helm, Docker, tarefas e
Orgmode. Para o usar, a mesma configuração deve estar disponível em
`~/.config/nvim-devops`, executando `NVIM_APPNAME=nvim-devops nvim`.
Tem plugins/dados próprios e usa `lazy-lock-devops.json` após a primeira atualização.

São necessários Neovim >= 0.11.2, Git, um compilador C e `rg` ou `fd`.
O Mason instala as ferramentas configuradas; os pacotes Python precisam de
Python com suporte a venv/pip e os servidores Node precisam de Node.js/npm.
O LazyVim gere a instalação do tree-sitter-cli quando necessário.

Em Debian/Ubuntu, se o Mason falhar por falta de dependências:

```sh
sudo apt install unzip python3-venv fd-find build-essential
```

Depois, reabra o Neovim para repetir as instalações em falta.

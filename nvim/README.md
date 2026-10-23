# Neovim / LazyVim

Configuração baseada em LazyVim, com Python (Pyright, Ruff, Black e debugpy),
Java, TypeScript/React, C#/.NET, ESLint, Prettier, Bash, JSON, Oil e pesquisa
de ficheiros pelo Snacks. Noice está desativado.

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

Para Java, é necessário um JDK compatível com o JDTLS instalado, além do JDK
usado pelo projeto. Para C#, instale o SDK .NET correspondente ao projeto
(`net10.0` requer o SDK .NET 10). Nos frontends, instale as dependências de cada
projeto para usar as versões locais de TypeScript, ESLint e Prettier.

O OmniSharp usa sincronização completa e permite restaurar pacotes NuGet.
O destaque automático de referências está desativado apenas neste servidor,
para contornar a exceção `ArgumentOutOfRangeException` em `documentHighlight`.
A pesquisa de referências continua disponível.

Se aparecer `Predefined type 'System.Object' is not defined or imported`,
execute na pasta da solução/projeto:

```sh
dotnet --version
dotnet restore
dotnet build --no-restore
```

Confirme que o SDK selecionado por `global.json` está instalado e que o build
resolve as referências do framework. Depois, reabra o Neovim na pasta da
solução (`.sln`/`.slnx`) ou do projeto (`.csproj`). Após alterar esta configuração,
reinicie o Neovim para recriar o cliente LSP.

Em Debian/Ubuntu, se o Mason falhar por falta de dependências:

```sh
sudo apt install unzip python3-venv fd-find build-essential
```

Depois, reabra o Neovim para repetir as instalações em falta.

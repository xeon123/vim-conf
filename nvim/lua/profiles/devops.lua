-- lua/profiles/devops.lua
return {
  -- Go IDE
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.test.core" },
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gotmpl" },
    dependencies = { "ray-x/guihua.lua" },
    opts = {
      gofmt = "gofumpt",
      fillstruct = "gopls",
      diagnostic = { virtual_text = true },
      lsp_cfg = false, -- let LazyVim/lspconfig own LSP servers
    },
    config = function(_, opts)
      require("go").setup(opts)
      vim.g.go_build_tags = ""
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = { "go" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },

  -- Helm & YAML/Kubernetes
  { "towolf/vim-helm", ft = { "helm", "yaml", "tpl" } },
  {
    "someone-stole-my-name/yaml-companion.nvim",
    ft = { "yaml", "yml" },
    dependencies = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      local yc = require("yaml-companion")
      local cfg = yc.setup({
        lspconfig = {
          settings = {
            yaml = {
              format = { enable = true },
              validate = true,
              hover = true,
              completion = true,
              schemas = yc.get_buf_schema(0),
              schemaStore = { enable = true },
              schemaDownload = { enable = true },
              kubernetes = { enabled = true },
            },
          },
        },
      })
      require("lspconfig").yamlls.setup(cfg)
    end,
  },

  -- Overseer tasks
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
    opts = { templates = {} },
    config = function(_, opts)
      require("overseer").setup(opts)
      local o = require("overseer")
      o.register_template({
        name = "Go: build current module",
        builder = function()
          return { cmd = { "go" }, args = { "build", "./..." }, components = { "default" } }
        end,
      })
      o.register_template({
        name = "Go: test with race",
        builder = function()
          return { cmd = { "go" }, args = { "test", "./...", "-race", "-v" }, components = { "default" } }
        end,
      })
      o.register_template({
        name = "kubectl: apply current file",
        builder = function()
          return { cmd = { "kubectl" }, args = { "apply", "-f", vim.fn.expand("%:p") }, components = { "default" } }
        end,
      })
      o.register_template({
        name = "helm: template ./chart",
        builder = function()
          return { cmd = { "helm" }, args = { "template", "./chart" }, components = { "default" } }
        end,
      })
    end,
  },

  -- Mason tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      for _, t in ipairs({
        -- Go
        "gopls",
        "delve",
        "golangci-lint",
        "gofumpt",
        "goimports-reviser",
        "golines",
        "gomodifytags",
        "iferr",
        "impl",
        "gotests",
        -- YAML/K8s
        "yaml-language-server",
        "yamlfmt",
        "yamllint",
        -- Helm LSP
        "helm-ls",
        -- Dockerfile
        "hadolint",
      }) do
        if not vim.tbl_contains(opts.ensure_installed, t) then
          table.insert(opts.ensure_installed, t)
        end
      end
      return opts
    end,
  },

  -- LSP servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              usePlaceholders = true,
              analyses = { unusedparams = true, nilness = true, unusedwrite = true, fieldalignment = false },
              hints = { rangeVariableTypes = true, parameterNames = true, constantValues = true },
            },
          },
        },
        yamlls = {}, -- configured by yaml-companion
        helm_ls = {}, -- mason installs "helm-ls"
      },
    },
  },

  -- Formatters
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.go = { "gofumpt", "goimports_reviser", "golines" }
      opts.formatters_by_ft.yaml = { "yamlfmt" }
      opts.formatters_by_ft.helm = { "yamlfmt" }
      return opts
    end,
  },

  -- Linters
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.go = { "golangci_lint" }
      opts.linters_by_ft.yaml = { "yamllint" }
      opts.linters_by_ft.dockerfile = { "hadolint" }
      return opts
    end,
  },

  -- Orgmode (no Neorg grammars)
  {
    "nvim-orgmode/orgmode",
    version = "*",
    ft = { "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("orgmode").setup_ts_grammar()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true, additional_vim_regex_highlighting = { "org" } },
        ensure_installed = { "org" },
      })
      require("orgmode").setup({
        org_agenda_files = { "~/org/planner/*" },
        org_default_notes_file = "~/org/refile.org",
      })
    end,
  },
}

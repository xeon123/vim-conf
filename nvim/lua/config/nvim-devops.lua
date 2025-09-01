-- lua/config/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local appname = vim.env.NVIM_APPNAME or "nvim"
local is_devops = (appname == "nvim-devops")

-- Extra DevOps plugins/specs (only loaded when NVIM_APPNAME=nvim-devops)
local function devops_spec()
  if not is_devops then return {} end
  return {
    -- Go IDE experience
    {
      "ray-x/go.nvim",
      ft = { "go", "gomod", "gotmpl" },
      dependencies = { "ray-x/guihua.lua" },
      opts = {
        gofmt = "gofumpt",
        fillstruct = "gopls",
        diagnostic = { virtual_text = true },
        lsp_cfg = false, -- let LazyVim/lspconfig handle servers
      },
      config = function(_, opts)
        require("go").setup(opts)
        -- optional: build tags per project
        vim.g.go_build_tags = ""
      end,
    },
    {
      "leoluz/nvim-dap-go",
      ft = { "go" },
      dependencies = { "mfussenegger/nvim-dap" },
      config = function() require("dap-go").setup() end,
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
          -- auto-detect Kubernetes schemas, merge with SchemaStore
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

    -- Task runner with useful DevOps tasks
    {
      "stevearc/overseer.nvim",
      cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
      opts = {
        templates = {
          -- Add custom templates below
        },
      },
      config = function(_, opts)
        require("overseer").setup(opts)
        local overseer = require("overseer")

        -- Go tasks
        overseer.register_template({
          name = "Go: build current module",
          builder = function()
            return { cmd = { "go" }, args = { "build", "./..." }, components = { "default" } }
          end,
        })
        overseer.register_template({
          name = "Go: test with race",
          builder = function()
            return { cmd = { "go" }, args = { "test", "./...", "-race", "-v" }, components = { "default" } }
          end,
        })

        -- K8s tasks (apply current file)
        overseer.register_template({
          name = "kubectl: apply current file",
          builder = function()
            local file = vim.fn.expand("%:p")
            return { cmd = { "kubectl" }, args = { "apply", "-f", file }, components = { "default" } }
          end,
        })

        -- Helm tasks (template current chart)
        overseer.register_template({
          name = "helm: template ./chart",
          builder = function()
            return { cmd = { "helm" }, args = { "template", "./chart" }, components = { "default" } }
          end,
        })
      end,
    },

    -- Extend LazyVim’s builtin tool managers for DevOps
    -- 1) Mason: ensure CLI/LSP tools are installed
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        opts = opts or {}
        opts.ensure_installed = opts.ensure_installed or {}
        local extra = {
          -- Go
          "gopls", "delve", "golangci-lint", "gofumpt", "goimports-reviser", "golines", "gomodifytags", "iferr", "impl", "gotests",
          -- YAML/K8s
          "yaml-language-server", "yamlfmt", "yamllint",
          -- Helm
          "helm-ls",
          -- Docker (often relevant in DevOps)
          "hadolint",
        }
        for _, t in ipairs(extra) do
          if not vim.tbl_contains(opts.ensure_installed, t) then table.insert(opts.ensure_installed, t) end
        end
        return opts
      end,
    },

    -- 2) LSP servers
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
          yamlls = {},       -- configured via yaml-companion (above)
          helm_ls = {},      -- helm language server (via mason "helm-ls")
        },
      },
    },

    -- 3) Formatters (Conform)
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

    -- 4) Linters (nvim-lint)
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
  }
end

require("lazy").setup({
  spec = vim.list_extend({
    -- LazyVim core + its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- your own extra plugins
    { import = "plugins" },
  }, devops_spec()),

  defaults = {
    lazy = false,
    version = false,
  },

  install = { colorscheme = { "tokyonight", "habamax" } },

  checker = {
    enabled = true,
    notify = false,
    frequency = 3600,
    concurrency = (vim.uv or vim.loop).available_parallelism and (vim.uv or vim.loop).available_parallelism() or 4,
  },

  -- per-profile lockfile
  lockfile = (vim.fn.stdpath("state") .. "/" .. appname .. "-lazy-lock.json"),

  git = { timeout = 120, filter = true, url_format = "https://github.com/%s.git" },

  performance = {
    cache = {
      enabled = true,
      path = (vim.fn.stdpath("data") .. "/" .. appname .. "-lazy-cache"),
      disable_events = { "VimEnter", "BufReadPre" },
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
        -- "matchit", "matchparen", -- enable if you need them
        -- "netrwPlugin",          -- keep enabled if you rely on netrw
      },
    },
  },

  ui = { border = "rounded", size = { width = 0.85, height = 0.85 }, pills = false, wrap = false },
})


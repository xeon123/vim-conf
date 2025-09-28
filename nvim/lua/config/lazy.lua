-- Bootstrap lazy.nvim
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local appname = vim.env.NVIM_APPNAME or "nvim"
local profile = (vim.env.NVIM_PROFILE or appname):lower()
profile = profile:gsub("^nvim%-", "")
if profile == "" or profile == "nvim" then
  profile = "main"
end

local function ensure_tools(opts, tools)
  opts.ensure_installed = opts.ensure_installed or {}
  for _, tool in ipairs(tools) do
    if not vim.tbl_contains(opts.ensure_installed, tool) then
      table.insert(opts.ensure_installed, tool)
    end
  end
end

local function preferred_files_cmd()
  if vim.fn.executable("fd") == 1 then
    return {
      "fd",
      "--type",
      "f",
      "--type",
      "l",
      "--hidden",
      "--follow",
      "--color",
      "never",
      "--exclude",
      ".git",
    }
  end

  return {
    "rg",
    "--files",
    "--hidden",
    "--follow",
    "--glob",
    "!.git/*",
  }
end

local mason_common_tools = {
  "lua-language-server",
  "stylua",
  "bash-language-server",
  "shfmt",
  "shellcheck",
  "marksman",
}

local mason_go_tools = {
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
  "yaml-language-server",
  "yamlfmt",
  "yamllint",
  "helm-ls",
  "hadolint",
}

local base_spec = {
  -- LazyVim core plus optional local plugins
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "plugins" },
}

local specs = vim.deepcopy(base_spec)

vim.list_extend(specs, {
  { import = "lazyvim.plugins.extras.ui.mini-animate" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.util.project" },
  {
    "stevearc/oil.nvim",
    opts = { default_file_explorer = true, view_options = { show_hidden = true } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory (oil)" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.defaults = opts.defaults or {}
      opts.defaults.find_command = preferred_files_cmd()
      return opts
    end,
  },
})

local profile_specs = {
  main = {
    -- Go IDE
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.test.core" },
    {
      "mason-org/mason.nvim",
      opts = function(_, opts)
        opts = opts or {}
        ensure_tools(opts, mason_common_tools)
        ensure_tools(opts, mason_go_tools)
        return opts
      end,
    },
    {
      "folke/which-key.nvim",
      optional = true,
      init = function()
        local paths = {
          "/usr/local/bin",
          "/usr/bin",
          vim.fn.expand("~/.local/bin"),
          vim.fn.expand("~/bin"),
          "/home/linuxbrew/.linuxbrew/bin",
        }
        local sep = (vim.loop.os_uname().sysname == "Windows_NT") and ";" or ":"
        for _, p in ipairs(paths) do
          if p ~= "" and not string.find(vim.env.PATH or "", vim.pesc(p), 1, true) then
            vim.env.PATH = (vim.env.PATH or "") .. sep .. p
          end
        end
      end,
    },
    {
      "folke/snacks.nvim",
      optional = true,
      opts = {
        picker = {
          sources = {
            files = {
              cmd = preferred_files_cmd,
            },
          },
        },
      },
    },

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
          yamlls = {},
          helm_ls = {},
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

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        if not ok then
          vim.notify("nvim-treesitter is not installed", vim.log.levels.WARN)
          return
        end
        configs.setup({
          ensure_installed = { "go", "gomod", "gosum", "gowork", "lua", "vim", "query" },
          highlight = { enable = true },
        })
      end,
    },
  },
}

for _, plugin in ipairs(profile_specs[profile] or {}) do
  table.insert(specs, plugin)
end

require("lazy").setup({
  spec = specs,

  defaults = { lazy = false, version = false },

  install = { colorscheme = { "tokyonight", "habamax" } },

  checker = {
    enabled = true,
    notify = false,
    -- aggressive but safe for big setups
    frequency = 3600,
    concurrency = (uv.available_parallelism and uv.available_parallelism() or 4),
  },

  -- Per-profile lock & cache to avoid cross-profile conflicts
  lockfile = (vim.fn.stdpath("state") .. "/" .. appname .. "-lazy-lock.json"),
  performance = {
    cache = {
      enabled = true,
      path = (vim.fn.stdpath("data") .. "/" .. appname .. "-lazy-cache"),
      disable_events = { "VimEnter", "BufReadPre" },
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        -- enable "matchit/matchparen/netrw" only if you need them
      },
    },
  },

  ui = { border = "rounded", size = { width = 0.85, height = 0.85 }, pills = false, wrap = false },
})

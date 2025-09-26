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
local profile = (appname == "nvim-devops") and "devops" or "main"

local specs = {
    -- LazyVim core + plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.util.project" },

    -- Common plugins you want everywhere (optional “plugins” dir if you use it)
    { import = "plugins" },
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
      opts = {
        defaults = {
          find_command = {
            "fd",
            "--type",
            "f",
            "--type",
            "l",
            "--color",
            "never",
            "--hidden",
            "-E",
            ".git",
          },
        },
      },
    },
  }

if profile == "main" then
  vim.list_extend(specs, {
    {
      "mason-org/mason.nvim",
      opts = function(_, opts)
        opts = opts or {}
        opts.ensure_installed = opts.ensure_installed or {}
        for _, t in ipairs({
          "lua-language-server",
          "stylua",
          "bash-language-server",
          "shfmt",
          "shellcheck",
          "marksman",
        }) do
          if not vim.tbl_contains(opts.ensure_installed, t) then
            table.insert(opts.ensure_installed, t)
          end
        end
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
              cmd = function()
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
              end,
            },
          },
        },
      },
    },
    {
      "nvim-telescope/telescope.nvim",
      optional = true,
      opts = {
        defaults = {
          find_command = {
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
          },
        },
      },
      init = function()
        if vim.fn.executable("fd") ~= 1 then
          local ok, telescope = pcall(require, "telescope")
          if ok then
            telescope.setup({
              defaults = {
                find_command = {
                  "rg",
                  "--files",
                  "--hidden",
                  "--follow",
                  "--glob",
                  "!.git/*",
                },
              },
            })
          end
        end
      end,
    },
  })
elseif profile == "devops" then
  table.insert(specs, { import = "profiles.devops" })
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
        -- enable “matchit/matchparen/netrw” only if you need them
      },
    },
  },

  ui = { border = "rounded", size = { width = 0.85, height = 0.85 }, pills = false, wrap = false },
})

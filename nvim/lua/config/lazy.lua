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

require("lazy").setup({
  spec = {
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
      "epwalsh/obsidian.nvim",
      version = "*",
      -- don't use `ft = "markdown"`; preload before FileType fires
      event = { "BufReadPre *.md", "BufNewFile *.md" },
      dependencies = {
        "nvim-lua/plenary.nvim",
        -- these can be lazy; cmp core is already forced above
        { "hrsh7th/cmp-buffer", enabled = false },
        { "hrsh7th/cmp-path", enabled = false },
        { "hrsh7th/cmp-nvim-lsp", enabled = false },
        { "hrsh7th/nvim-cmp", enabled = false },
        { "hrsh7th/cmp-buffer", enabled = false },
        { "saadparwaiz1/cmp_luasnip", enabled = false },
        { "L3MON4D3/LuaSnip", enabled = false }, -- if you don't actually use it with blink
      },
      -- only load if at least one workspace dir exists (or create them)
      cond = function()
        local dirs = {
          vim.fn.expand("~/Documents/KCNA-Notes"),
          vim.fn.expand("~/Documents/CKA-Notes"),
          vim.fn.expand("~/Documents/ist-sidc"),
        }
        local any = false
        for _, d in ipairs(dirs) do
          if vim.fn.isdirectory(d) == 1 then
            any = true
          end
        end
        return any
      end,
      opts = function()
        -- create missing vaults automatically (comment out if you prefer not to)
        local function ensure(dir)
          if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
          end
        end
        ensure(vim.fn.expand("~/Documents/KCNA-Notes"))
        ensure(vim.fn.expand("~/Documents/CKA-Notes"))
        ensure(vim.fn.expand("~/Documents/ist-sidc"))

        return {
          workspaces = {
            { name = "kcna", path = "~/Documents/KCNA-Notes" },
            { name = "cka", path = "~/Documents/CKA-Notes" },
            { name = "msidc", path = "~/Documents/ist-sidc" },
          },
          daily_notes = { folder = "daily", date_format = "%Y-%m-%d" },
          completion = { nvim_cmp = true },
        }
      end,
    },
    {
      "saghen/blink.cmp",
      version = "*",
      opts = {
        keymap = { preset = "default" },
        sources = { default = { "lsp", "path", "buffer" } },
      },
    },

    -- Profile-specific specs
    { import = "profiles." .. profile },
  },

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

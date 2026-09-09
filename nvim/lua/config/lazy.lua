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
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "lazyvim.plugins.extras.ui.mini-animate" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.util.project" },
}

if profile == "devops" then
  table.insert(specs, { import = "profiles.devops" })
end
-- User overrides must follow LazyVim extras.
table.insert(specs, { import = "plugins" })

require("lazy").setup({
  spec = specs,

  defaults = { lazy = false, version = false },

  install = { colorscheme = { "tokyonight", "habamax" } },

  checker = {
    enabled = true,
    notify = false,
    frequency = 3600,
  },

  -- Keep reproducible plugin versions in the configuration repository.
  lockfile = vim.fn.stdpath("config") .. (profile == "devops" and "/lazy-lock-devops.json" or "/lazy-lock.json"),
  performance = {
    reset_packpath = true,
    rtp = {
      -- Treesitter's health check compares the install path with a trailing slash.
      paths = { vim.fn.stdpath("data") .. "/site/" },
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

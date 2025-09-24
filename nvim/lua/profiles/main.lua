-- lua/profiles/main.lua
return {
  -- Examples: add LazyVim extras you care about
  -- { import = "lazyvim.plugins.extras.lang.go" },
  -- { import = "lazyvim.plugins.extras.coding.copilot" },
  -- { import = "lazyvim.plugins.extras.ui.mini-animate" },

  -- Extend core behavior a bit:
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      for _, t in ipairs({
        -- Fast QoL on fresh machines
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
  -- Make sure PATH inside nvim can see fd
  {
    -- dummy plugin spec to run early
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

  -- Snacks picker: force fd with robust args + fallback
  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        sources = {
          files = {
            -- Prefer fd if present
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
              -- Fallback: ripgrep file listing
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

  -- Telescope: match fd behavior for consistency
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
    -- If fd is missing, transparently swap to rg
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
}

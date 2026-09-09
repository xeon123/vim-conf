-- Common Python and shell tools; language integrations are imported in config.lazy.
return {
  {
    "linux-cultist/venv-selector.nvim",
    -- Its automatic Python-file hook requires fd; keep Python usable without it.
    enabled = vim.fn.executable("fd") == 1 or vim.fn.executable("fdfind") == 1,
  },
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { bashls = {} } },
  },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { python = { "black" }, sh = { "shfmt" } } },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, tool in ipairs({ "stylua", "black", "shfmt", "shellcheck", "marksman" }) do
        if not vim.tbl_contains(opts.ensure_installed, tool) then
          table.insert(opts.ensure_installed, tool)
        end
      end
    end,
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { default_file_explorer = true, view_options = { show_hidden = true } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" } },
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = false },
      picker = { sources = { files = { hidden = true, follow = true, exclude = { ".git" } } } },
    },
    init = function()
      -- Snacks checks optional image tools (including mmdc) even when disabled.
      require("snacks").image.meta.health = false
    end,
  },
}

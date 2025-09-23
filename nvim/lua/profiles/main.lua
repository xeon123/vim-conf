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
}

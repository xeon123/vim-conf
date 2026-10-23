return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          cmd = {
            "omnisharp",
            "-z",
            "--hostPID",
            tostring(vim.fn.getpid()),
            "DotNet:enablePackageRestore=true",
            "--encoding",
            "utf-8",
            "--languageserver",
          },
          -- Send complete documents to avoid stale line offsets after edits.
          flags = { allow_incremental_sync = false },
          on_init = function(client)
            -- FindUsages can throw on documentHighlight while the workspace reloads.
            -- Disable automatic highlights for this server; references still work.
            client.server_capabilities.documentHighlightProvider = false
          end,
          settings = {
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = true,
              EnableImportCompletion = true,
            },
            FormattingOptions = { OrganizeImports = true },
          },
        },
      },
    },
  },
}

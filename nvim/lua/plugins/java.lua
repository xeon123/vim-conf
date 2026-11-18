return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local customize = opts.jdtls
      opts.jdtls = function(config)
        if type(customize) == "function" then
          config = customize(config) or config
        elseif customize then
          config = vim.tbl_deep_extend("force", config, customize)
        end

        -- Test runner/agent jars are not OSGi extensions. Mason may also
        -- expose aliases, and JDTLS already ships some of these bundles.
        local mason = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
        local seen = {}
        config.init_options.bundles = vim.tbl_filter(function(path)
          local name = vim.fs.basename(path)
          if name == "com.microsoft.java.test.runner-jar-with-dependencies.jar" or name == "jacocoagent.jar" then
            return false
          end
          if vim.uv.fs_stat(mason .. "/packages/jdtls/plugins/" .. name) then
            return false
          end
          local real = vim.uv.fs_realpath(path) or path
          if seen[real] then
            return false
          end
          seen[real] = true
          return true
        end, config.init_options.bundles or {})
        return config
      end
    end,
  },
}

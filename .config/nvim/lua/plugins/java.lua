return {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
        local jdtls = require("jdtls")
        local jdtls_setup = require("jdtls.setup")
        local home = os.getenv("HOME")
        local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
        local lombok_path = home .. "/.local/share/java/lombok.jar"
        local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local workspace_dir = home .. "/.cache/jdtls/workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

        local config = {
            cmd = {
                "java",
                "-javaagent:" .. lombok_path,
                "-Xmx1G",
                "--add-modules=ALL-SYSTEM",
                "--add-opens", "java.base/java.util=ALL-UNNAMED",
                "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                "-jar", launcher_jar,
                "-configuration", jdtls_path .. "/config_linux",
                "-data", workspace_dir,
            },
            root_dir = jdtls_setup.find_root({ "gradlew", "mvnw", ".git" }),
            capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                require("cmp_nvim_lsp").default_capabilities()
            ),
        }

        -- Delay until filetype = java and buffer is fully loaded
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                jdtls.start_or_attach(config)
            end,
        })
    end

}

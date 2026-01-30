return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                unusedLocalExclude = { "_*" },
              },
            },
          },
        },
        eslint = {
          flags = {
            allow_incremental_sync = false,
            debounce_text_changes = 1000,
          },
        },
        tailwindcss = {
          enabled = false,
        },
        tsserver = {
          enabled = false,
          cmd = { "typescript-language-server", "--stdio" },
        },
        angularls = {
          filetypes = {
            "typescript",
            "html",
            "htmlangular",
            "typescriptreact",
            "javascriptreact",
            "typescript.tsx",
            "javascript",
            "javascript.jsx",
          },
          on_attach = function(client, _bufnr)
            client.server_capabilities.definitionProvider = true
            client.server_capabilities.typeDefinitionProvider = true
            -- Disable capabilities that conflict with vtsls
            client.server_capabilities.referencesProvider = false
            client.server_capabilities.implementationProvider = false
            client.server_capabilities.renameProvider = false
          end,
        },
        -- vtsls = {
        -- enabled = false,
        -- cmd = { "typescript-language-server", "--stdio" },
        -- filetypes = {
        --   "javascript",
        --   "javascriptreact",
        --   "javascript.jsx",
        --   "typescript",
        --   "typescriptreact",
        --   "typescript.tsx",
        -- },
        -- init_options = {
        --   preferences = {
        --     includeInlayParameterNameHints = "literals",
        --     includeInlayFunctionParameterTypeHints = true,
        --     includeInlayPropertyDeclarationTypeHints = true,
        --     includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        --     includeInlayVariableTypeHints = false,
        --     includeInlayFunctionLikeReturnTypeHints = false,
        --     includeInlayEnumMemberValueHints = false,
        --   },
        -- },
        -- root_dir = function(fname)
        --   return find_root(fname)
        -- end,
        -- },
        bashls = {
          settings = {
            bashIde = {
              shellcheckArguments = { "-e", "SC2034" },
            },
          },
        },
        dartls = {
          cmd = { "dart", "language-server", "--protocol=lsp" },
          filetypes = { "dart" },
          init_options = {
            onlyAnalyzeProjectsWithOpenFiles = true,
            suggestFromUnimportedLibraries = true,
            closingLabels = true,
            outline = true,
            flutterOutline = true,
          },
          settings = {
            dart = {
              completeFunctionCalls = true,
              showTodos = true,
            },
          },
        },
      },
    },
  },
}

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
          -- enabled = false,
          cmd = { "typescript-language-server", "--stdio" },
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

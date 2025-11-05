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
        tailwindcss = {
          enabled = false,
        },
        -- tsserver = {
        --   cmd = { "typescript-language-server", "--stdio" },
        -- },
        vtsls = {
          enabled = false,
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
        },
        bashls = {
          settings = {
            bashIde = {
              shellcheckArguments = { "-e", "SC2034" },
            },
          },
        },
      },
    },
  },
}

local function eslint_fix_all(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  vim.validate("bufnr", bufnr, "number")
  local client = opts.client or vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })[1]
  if not client then
    return
  end
  local request
  if opts.sync then
    request = function(buf, method, params)
      client:request_sync(method, params, nil, buf)
    end
  else
    request = function(buf, method, params)
      client:request(method, params, nil, buf)
    end
  end
  request(bufnr, "workspace/executeCommand", {
    command = "eslint.applyAllFixes",
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = vim.lsp.util.buf_versions[bufnr],
      },
    },
  })
end

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
          -- flags = {
          --   allow_incremental_sync = false,
          --   debounce_text_changes = 1000,
          -- },
          -- settings = {
          --   workingDirectories = { mode = "auto" },
          -- },
          on_init = function(client)
            vim.api.nvim_create_user_command("EslintFixAll", function()
              eslint_fix_all({ client = client, sync = true })
            end, {})
          end,
          on_attach = function(_client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "silent! EslintFixAll",
            })
          end,
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

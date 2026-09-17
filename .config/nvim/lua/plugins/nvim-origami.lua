return {
  "chrisgrieser/nvim-origami",
  event = "VeryLazy",
  opts = {
    useLspFoldsWithTreesitterFallback = {
      enabled = true,
      foldmethodIfNeitherIsAvailable = "indent",
    },
    pauseFoldsOnSearch = true,
    foldtext = {
      enabled = true,
      padding = {
        width = 3,
      },
      lineCount = {
        template = "%d lines",
        hlgroup = "Comment",
      },
      diagnosticsCount = true,
      gitsignsCount = true,
      disableOnFt = { "snacks_picker_input" },
    },
    autoFold = {
      enabled = true,
      kinds = { "imports" },
    },
    foldKeymaps = {
      setup = false, -- modifies `h`, `l`, `^`, and `$`
      closeOnlyOnFirstColumn = true, -- `h` and `^` only close in the 1st column
      scrollLeftOnCaret = false, -- `^` should scroll left (basically mapped to `0^`)
    },
  },
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
  end,
  config = function(_, opts)
    require("origami").setup(opts)

    -- Workaround for https://github.com/chrisgrieser/nvim-origami/issues/61
    -- `vim.lsp.foldclose()` silently no-ops when called immediately on
    -- `didOpen`, because Neovim's internal LSP fold state doesn't exist
    -- yet at that point. Replace origami's autofold autocmd (same augroup
    -- name, so this clears and takes over from it) with a version that
    -- retries until the fold state is ready and folding ranges arrive.
    vim.api.nvim_create_autocmd("LspNotify", {
      desc = "Origami: Close imports and comments on load (with retry, see origami#61)",
      group = vim.api.nvim_create_augroup("origami.autofolds", { clear = true }),
      callback = function(ctx)
        if ctx.data.method ~= "textDocument/didOpen" then
          return
        end
        if vim.bo[ctx.buf].buftype ~= "" or not vim.api.nvim_buf_is_valid(ctx.buf) then
          return
        end

        vim.schedule(function()
          local client = vim.lsp.get_clients({ bufnr = ctx.buf, id = ctx.data.client_id })[1]
          if not client or not client:supports_method("textDocument/foldingRange") then
            return
          end

          local kinds = require("origami.config").config.autoFold.kinds
          local winid = vim.fn.bufwinid(ctx.buf)
          if not winid or winid == -1 or not vim.api.nvim_win_is_valid(winid) then
            return
          end

          local tries = 0
          local function try()
            if not vim.api.nvim_win_is_valid(winid) or vim.api.nvim_win_get_buf(winid) ~= ctx.buf then
              return
            end
            tries = tries + 1

            local anyClosed = vim.api.nvim_win_call(winid, function()
              -- Force creation of Neovim's internal LSP fold state.
              vim.fn.foldlevel(1)
              local closed = false
              for _, kind in ipairs(kinds) do
                local success = pcall(vim.lsp.foldclose, kind, winid)
                vim.b[ctx.buf].origami_has_autofolded = success
              end
              closed = vim.fn.foldclosed(1) ~= -1
              return closed
            end)

            if not anyClosed and tries < 10 then
              vim.defer_fn(try, 200)
            end
          end
          try()
        end)
      end,
    })
  end,
}

return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime, and plugins
    -- used for completion, annotations, and signatures of Neovim APIs
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load `luvit` types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
      enabled = function(_) return vim.g.lazydev_enabled == true end,
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by `blink.cmp`
      'saghen/blink.cmp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM machines) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(
              mode,
              keys,
              func,
              { buffer = event.buf, desc = 'LSP: ' .. desc }
            )
          end

          local Snacks = require 'snacks'

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Find references for the word under your cursor.
          map(
            'grr',
            function() Snacks.picker.lsp_references() end,
            '[G]oto [R]eferences'
          )

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          map(
            'gri',
            function() Snacks.picker.lsp_implementations() end,
            '[G]oto [I]mplementation'
          )

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          map(
            'grd',
            function() Snacks.picker.lsp_definitions() end,
            '[G]oto [D]efinition'
          )

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map(
            'go',
            function() Snacks.picker.lsp_symbols() end,
            '[G]oto [O]pen Document Symbols'
          )

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map(
            'gw',
            function() Snacks.picker.lsp_workspace_symbols() end,
            '[G]oto [W]orkspace Symbols'
          )

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map(
            'grt',
            function() Snacks.picker.lsp_type_definitions() end,
            '[G]oto [T]ype Definition'
          )

          -- Showing & navigating diagnostics
          vim.diagnostic.config { virtual_text = false }
          map(
            '<leader>d',
            vim.diagnostic.open_float,
            '[S]how [D]iagnostic on the current line'
          )
          local function _jump_to_target_diagnostic(target_diagnostic)
            if target_diagnostic then
              vim.diagnostic.jump { diagnostic = target_diagnostic, float = true }
            end
          end
          map(
            ']d',
            function() _jump_to_target_diagnostic(vim.diagnostic.get_next()) end,
            '[N]ext [D]iagnostic'
          )
          map(
            '[d',
            function() _jump_to_target_diagnostic(vim.diagnostic.get_prev()) end,
            '[P]revious [D]iagnostic'
          )

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map(
              '<leader>th',
              function()
                vim.lsp.inlay_hint.enable(
                  not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
                )
              end,
              '[T]oggle Inlay [H]ints'
            )
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add `blink.cmp`, `luasnip`, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with `blink.cmp`, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities(nil, true)
      -- Sets capabilities for EVERY server globally
      vim.lsp.config('*', { capabilities = capabilities })
      local lsp_names = vim.tbl_map(
        function(o) return type(o) == 'string' and o or o[1] end,
        require 'config.required_tools' 'lsp'
      )
      vim.lsp.enable(lsp_names)
    end,
  },
}

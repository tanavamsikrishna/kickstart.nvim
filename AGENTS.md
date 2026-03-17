# kickstart.nvim

This is a highly customized and modular Neovim configuration, evolved from the original [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) template. It serves as a modern, feature-rich development environment optimized for speed, aesthetics, and productivity.

## Project Overview

### Core Technologies
- **Neovim**: Targets latest stable or nightly versions (v0.10+ recommended).
- **Lua**: The primary language for configuration and extensibility.
- **lazy.nvim**: A modern plugin manager for Neovim that handles installation, updates, and lazy-loading.

### Architecture
The configuration is structured to be both modular and easy to navigate:

- **`init.lua`**: The entry point. It bootstraps `lazy.nvim`, sets global options, basic keymaps, and autocommands. It imports all plugin specifications from the `lua/plugins/` directory.
- **`lua/plugins/`**: Contains modular Lua files, each defining one or more plugins and their configurations (e.g., `lsp.lua`, `treesitter.lua`, `snacks.lua`).
- **`lua/config/`**: Contains system-level and UI configuration modules:
    - `required_tools.lua`: A centralized manifest of LSP servers (e.g., `pyright`, `rust_analyzer`, `vtsls`) and CLI tools (e.g., `stylua`, `prettierd`) used by the setup.
    - `folding.lua`, `mksession.lua`, `neovide.lua`, etc.: Specialized settings for various features.
- **`snippets/`**: Custom Lua-based snippets for multiple languages.

## Building and Running

## Development Conventions

- **Code Style**: Lua code is formatted using `stylua` (see `.stylua.toml`).
- **Linting**: Lua files are linted using `luacheck` (see `.luacheckrc`).
- **Modularity**: When adding new plugins, prefer creating a new file in `lua/plugins/` rather than modifying `init.lua`.
- **Keymaps**: Custom keymaps generally use the `<leader>` key (mapped to `Space`).
- **LSP Configuration**: Managed via `nvim-lspconfig` with `blink.cmp` for autocompletion. Required LSPs should be added to `lua/config/required_tools.lua`.

## GUI Testing & Verification

- **GUI Detection**: When testing or verifying GUI-specific behavior (e.g., `has('gui_running')`, `vim.g.neovide`), do NOT use `nvim --headless`. Headless mode does not attach a UI and will return false for these checks.
- **Verification Command**: To verify GUI state from the shell, use Neovide's blocking mode:
  ```bash
  neovide --no-fork -- -c "lua print(vim.fn.has('gui_running'))" -c "qa"
  ```

## Plugin install location
1. Plugins are installed to the directory `~/.local/share/nvim/lazy`. Each plugin is installed in a directory at the root of this directory. Search inside this directory if you are looking for plugin related code. Limit your search to with specific plugin directories if viable.
2. Most of the relevant Neovim source code is located at `/opt/homebrew/Cellar/neovim/<neovim-version>/share/nvim/runtime` (`<neovim-version>` is of the format `<major>.<minor>.<patch>` You can get the version details using `nvim --version`).

Both of these two locations will have a lot files and code. The `lua` files are the most useful if you want to understand the functionality.
To inspect the runtime behaviour of neovim you can connect to a running neovim instance using 
`nvim --clean --headless --server ./.nvim_socket ...` style commands.

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

### Prerequisites
Ensure the following tools are installed on your system:
- **Neovim** (v0.10+)
- **Build Tools**: `git`, `make`, `unzip`, `gcc` (or another C compiler).
- **CLI Utilities**: `ripgrep` (`rg`), `fd-find` (`fd`).
- **Font**: A [Nerd Font](https://www.nerdfonts.com/) is highly recommended for proper icon rendering.

### Installation
1. Clone this repository to your Neovim configuration path:
   ```bash
   git clone https://github.com/vamsi/kickstart.nvim.git ~/.config/nvim
   ```
2. Launch Neovim:
   ```bash
   nvim
   ```
   On the first run, `lazy.nvim` will automatically download and install all configured plugins.

### Key Commands
- `:Lazy`: Open the plugin manager interface.
- `:Mason`: Manage LSP servers, linters, and formatters.
- `<leader>sf`: Search files using the Snacks picker.
- `<leader>sg`: Live grep through the project.
- `<leader>sh`: Search help documentation.
- `<leader>sk`: Search keymaps.

## Development Conventions

- **Code Style**: Lua code is formatted using `stylua` (see `.stylua.toml`).
- **Linting**: Lua files are linted using `luacheck` (see `.luacheckrc`).
- **Modularity**: When adding new plugins, prefer creating a new file in `lua/plugins/` rather than modifying `init.lua`.
- **Keymaps**: Custom keymaps generally use the `<leader>` key (mapped to `Space`).
- **LSP Configuration**: Managed via `nvim-lspconfig` with `blink.cmp` for autocompletion. Required LSPs should be added to `lua/config/required_tools.lua`.

## Key Plugins and Integrations

- **LSP**: `nvim-lspconfig`, `mason.nvim`.
- **Completion**: `blink.cmp` (fast, Rust-based fuzzy matching).
- **Syntax**: `nvim-treesitter` for advanced highlighting and text objects.
- **Fuzzy Finder**: `snacks.nvim` (Picker module).
- **Git**: `gitsigns.nvim` for gutter signs and hunk management.
- **UI**: `mini.statusline` for a lightweight status bar, `mini.icons` for iconography, `fidget.nvim` for notifications.
- **Productivity**:  `flash.nvim`, `todo-comments.nvim`.
- **Debugging**: `nvim-dap` for integrated debugging.

# Point ~/.config/nvim at this repo. External tools (LSPs, formatters, linters)
# are installed by machine manifests (Brewfile, mise, etc),
# # not from this config.
ln -sfh $env.FILE_PWD ~/.config/nvim
print $"(ansi red)Neovim setup also needs a nerd font installed(ansi reset)"

if vim.g.neovide then
  vim.o.guifont = 'JetBrainsMono Nerd Font:h13'
  -- vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0
  -- vim.opt.linespace = 1
  vim.g.have_nerd_font = true
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.2

  -- Floating window config
  -- vim.g.neovide_floating_blur_amount_x = 0
  -- vim.g.neovide_floating_blur_amount_y = 0.0
  vim.g.neovide_floating_shadow = true
  -- vim.g.neovide_floating_z_height = 10
  -- vim.g.neovide_light_angle_degrees = 45
  -- vim.g.neovide_light_radius = 5
  -- vim.g.neovide_floating_corner_radius = 0.5

  vim.g.neovide_input_macos_option_key_is_meta = 'both'
  vim.g.neovide_hide_mouse_when_typing = true
end

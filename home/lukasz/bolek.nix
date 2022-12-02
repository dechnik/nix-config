{ inputs, ... }: {
  imports = [ ./global ];
  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;
}

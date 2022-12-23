{ inputs, ... }: {
  imports = [
    ./global
    ./features/cli/tmux.nix
  ];
  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;
}

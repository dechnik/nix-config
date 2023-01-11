{ inputs, ... }: {
  imports = [
    ./global
    ./features/cli/tmux.nix
    ./features/trusted
    ./features/desktop/hyprland
    ./features/desktop/terminal
  ];
  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  monitors = [
  ];
  wallpaper = "";
}

{ inputs, ... }: {
  imports = [
    ./global
    ./features/cli/tmux.nix
    ./features/desktop/optional/software-render.nix
    ./features/trusted
    ./features/desktop/hyprland
    ./features/desktop/common/wayland-wm/sway.nix
  ];
  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  monitors = [
  ];
  wallpaper = "";
}

{ inputs, ... }: {
  imports = [
    ./global
    ./features/emacs
    ./features/trusted
    ./features/desktop/hyprland
    ./features/desktop/terminal
  ];

  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # My setup's layout:
  #  ------   -----
  # | DP-2 | | DP-1|
  #  ------   -----
  monitors = [
    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      refreshRate = 75;
      workspace = "1";
      enabled = true;
    }
    {
      name = "DP-1";
      isSecondary = true;
      width = 2560;
      height = 1440;
      x = 2560;
      workspace = "2";
      enabled = true;
    }
  ];
}

{ inputs, ... }:
{
  imports = [
    ./global
    ./features/desktop/hyprland
  ];

  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  mailhost = "dziad";

  # My setup's layout:
  #  ------   -----
  # | DP-2 | | DP-1|
  #  ------   -----
  monitors = [
    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      x = 0;
      y = 0;
      refreshRate = 75;
      workspace = "1";
      isPrimary = true;
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1440;
      x = 2560;
      y = 0;
      workspace = "9";
    }
    {
      name = "HDMI-A-1";
      width = 3840;
      height = 2160;
      refreshRate = 120;
      x = 5120;
      y = 0;
      workspace = "8";
    }
  ];

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://raw.githubusercontent.com/dechnik/nix-config/master/home/lukasz/features/desktop/wall.png";
    sha256 = "37bfdbb9cd427e2c6ebee1de458f6a96704d47962220332c5b7e2e316fef77e0";
  };
}

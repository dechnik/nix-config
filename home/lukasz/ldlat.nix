{ inputs, ... }: {
  imports = [
    ./global
    ./features/emacs
    ./features/trusted
    ./features/desktop/optional/nvidia.nix
    ./features/desktop/hyprland
  ];

  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # My setup's layout:
  #  ------   -----
  # | DP-2 | | DP-1|
  #  ------   -----
  monitors = [
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      y = 1080;
      workspace = "1";
      isPrimary = true;
    }
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      x = 1920;
      y = 1080;
      workspace = "10";
    }
    {
      name = "DVI-I-2";
      width = 1920;
      height = 1080;
      workspace = "8";
    }
    {
      name = "DVI-I-1";
      width = 1920;
      height = 1080;
      x = 1920;
      workspace = "9";
    }
  ];

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://git.sr.ht/~lukasz/dotfiles/blob/master/home/graphical/files/config/wallpaper.png";
    sha256 = "37bfdbb9cd427e2c6ebee1de458f6a96704d47962220332c5b7e2e316fef77e0";
  };
}

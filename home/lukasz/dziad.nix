{ inputs, ... }: {
  imports = [
    ./global
    ./features/emacs
    ./features/trusted
    ./features/trusted/mail
    ./features/trusted/mail/personal.nix
    ./features/trusted/mail/work.nix
    ./features/games
    ./features/desktop/optional/nvidia.nix
    ./features/desktop/optional/work.nix
    ./features/desktop/hyprland/nvidia.nix
    ./features/desktop/hyprland
    ./features/desktop/optional/bluetooth.nix
  ];

  home.sessionVariables = {
    HOSTNAME = "dziad";
  };

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
  ];

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://git.sr.ht/~lukasz/dotfiles/blob/master/home/graphical/files/config/wallpaper.png";
    sha256 = "37bfdbb9cd427e2c6ebee1de458f6a96704d47962220332c5b7e2e316fef77e0";
  };
}

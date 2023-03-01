{ inputs, ... }: {
  imports = [
    ./global
    ./features/emacs
    ./features/cli/work.nix
    ./features/trusted
    ./features/trusted/mail
    ./features/trusted/mail/personal.nix
    ./features/trusted/mail/work.nix
    ./features/desktop/hyprland/displaylink.nix
    ./features/desktop/hyprland
    ./features/desktop/optional/work.nix
    ./features/desktop/optional/bluetooth.nix
  ];

  home.sessionVariables = {
    HOSTNAME = "ldlat";
  };

  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  mailhost = "ldlat";

  # My setup's layout:
  #  ------   -----
  # | DP-2 | | DP-1|
  #  ------   -----
  monitors = [
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      x = 0;
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
      x = 0;
      y = 0;
      workspace = "8";
    }
    {
      name = "DVI-I-1";
      width = 1920;
      height = 1080;
      x = 1920;
      y = 0;
      workspace = "9";
    }
  ];
  services = {
    kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
            }
          ];
        };
        docked-all = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "1920,1080";
            }
            {
              criteria = "HDMI-A-1";
              position = "0,1080";
            }
            {
              criteria = "DVI-I-2";
              position = "0,0";
            }
            {
              criteria = "DVI-I-1";
              position = "1920,0";
            }
          ];
        };
      };
    };
  };

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://git.sr.ht/~lukasz/dotfiles/blob/master/home/graphical/files/config/wallpaper.png";
    sha256 = "37bfdbb9cd427e2c6ebee1de458f6a96704d47962220332c5b7e2e316fef77e0";
  };
}

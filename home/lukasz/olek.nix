{ pkgs, inputs, ... }:
{
  imports = [
    ./global
    ./features/desktop/optional/software-render.nix
    ./features/trusted
    # ./features/desktop/common/cosmic
    ./features/desktop/common
    ./features/desktop/hyprland
    # ./features/desktop/common/wayland-wm/sway.nix
  ];
  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  home.packages = with pkgs; [ google-chrome ];

  monitors = [ ];

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://raw.githubusercontent.com/dechnik/nix-config/master/home/lukasz/features/desktop/wall.png";
    sha256 = "37bfdbb9cd427e2c6ebee1de458f6a96704d47962220332c5b7e2e316fef77e0";
  };
}

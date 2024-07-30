{ inputs, pkgs, ... }:
{
  imports = [
    ./kitty.nix
    ./wofi.nix
    ./waybar.nix
    ./qutebrowser.nix
    ./zathura.nix
  ];
  home.packages = with pkgs; [
    inputs.hyprwm-contrib.packages.${system}.grimblast
    glib
    gsettings-desktop-schemas
    grim
    imv
    mimeo
    slurp
    waypipe
    wlogout
    wf-recorder
    wl-clipboard
    wl-mirror
    wl-mirror-pick
    ydotool
    nwg-displays
  ];

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };
}

{ pkgs, ... }:
{
  imports = [
    ./kitty.nix
    ./wofi.nix
    ./waybar.nix
    ./qutebrowser.nix
    ./zathura.nix
  ];
  home.packages = with pkgs; [
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
  ];

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}

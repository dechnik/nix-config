{ pkgs, ... }:
{
  imports = [
    ./kitty.nix
    ./wofi.nix
    ./waybar.nix
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

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
}

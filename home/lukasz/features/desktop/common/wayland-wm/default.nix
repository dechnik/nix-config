{ pkgs, ... }:
{
  imports = [
    ./cliphist.nix
    # ./gammastep.nix
    # ./kitty.nix
    ./alacritty.nix
    # ./foot.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./wofi.nix
    ./zathura.nix
    ./qutebrowser.nix
    ./waybar.nix
    ./waypipe.nix
  ];
  home.packages = with pkgs; [
    glib
    gsettings-desktop-schemas
    grim
    imv
    mimeo
    primary-xwayland
    pulseaudio
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
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
}

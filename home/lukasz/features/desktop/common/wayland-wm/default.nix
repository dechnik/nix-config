{ pkgs, ... }:
{
  home.packages = with pkgs; [
    grim
    imv
    lyrics
    mimeo
    # primary-xwayland
    pulseaudio
    slurp
    waypipe
    wf-recorder
    wl-clipboard
    wl-mirror
    # wl-mirror-pick
    ydotool
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = true;
    QT_QPA_PLATFORM = "wayland";
    # LIBSEAT_BACKEND = "logind";
  };
}
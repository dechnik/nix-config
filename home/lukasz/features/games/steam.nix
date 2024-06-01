{ pkgs, config, lib, ... }:
let
  # steam-with-pkgs = pkgs.steam.override {
  #   extraPkgs = pkgs: with pkgs; [
  #     xorg.libXcursor
  #     xorg.libXi
  #     xorg.libXinerama
  #     xorg.libXScrnSaver
  #     libpng
  #     libpulseaudio
  #     libvorbis
  #     stdenv.cc.cc.lib
  #     libkrb5
  #     keyutils
  #     gamescope
  #     mangohud
  #   ];
  # };
  monitor = lib.head (lib.filter (m: m.isPrimary) config.monitors);
  steam-session = pkgs.writeTextDir "share/wayland-sessions/steam-sesson.desktop" ''
    [Desktop Entry]
    Name=Steam Session
    Exec=${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} --expose-wayland -O ${monitor.name} -e -- steam -gamepadui
    Type=Application
  '';
in
{
  xdg = {
    desktopEntries = {
      steam-ses = {
        name = "Steam Session";
        exec = "${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} --expose-wayland -f -O ${monitor.name} -e -- steam -gamepadui";
        type = "Application";
      };
      steam-ses-keyboard = {
        name = "Steam Session Keyboard";
        exec = "${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} --expose-wayland -f -O ${monitor.name} -e -- steam";
        type = "Application";
      };
      steam-ses-tv = {
        name = "Steam Session TV";
        exec = "${pkgs.gamescope}/bin/gamescope -W 3840 -H 2160 -f -O HDMI-A-1 --expose-wayland -e -- steam -gamepadui";
        type = "Application";
      };
      steam-ses-tv-keyboard = {
        name = "Steam Session TV Keyboard";
        exec = "${pkgs.gamescope}/bin/gamescope -W 3840 -H 2160 -f --expose-wayland -O HDMI-A-1 -e -- steam";
        type = "Application";
      };
    };
  };
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\\\${HOME}/.steam/root/compatibilitytools.d";
  };
  home.packages = with pkgs; [
    # steam-with-pkgs
    # gamescope
    steam-session
    protonup
  ];
}

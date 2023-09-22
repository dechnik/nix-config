{ pkgs, config, lib, ... }:
let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils
      gamescope
      mangohud
    ];
  };
  monitor = lib.head (lib.filter (m: m.isPrimary) config.monitors);
  steam-session = pkgs.writeTextDir "share/wayland-sessions/steam-sesson.desktop" ''
    [Desktop Entry]
    Name=Steam Session
    Exec=${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} -O ${monitor.name} -e -- steam -gamepadui
    Type=Application
  '';
in
{
  xdg = {
    desktopEntries = {
      steam-ses = {
        name = "Steam Session";
        exec = "${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} -O ${monitor.name} -e -- steam -gamepadui";
        type = "Application";
      };
      steam-ses-keyboard = {
        name = "Steam Session Keyboard";
        exec = "${pkgs.gamescope}/bin/gamescope -g --force-grab-cursor -W ${toString monitor.width} -H ${toString monitor.height} -O ${monitor.name} -e -- steam";
        type = "Application";
      };
      steam-ses-tv = {
        name = "Steam Session TV";
        exec = "${pkgs.gamescope}/bin/gamescope -W 3840 -H 2160 -O HDMI-A-1 -e -- steam -gamepadui";
        type = "Application";
      };
      steam-ses-tv-keyboard = {
        name = "Steam Session TV Keyboard";
        exec = "${pkgs.gamescope}/bin/gamescope -g --force-grab-cursor -W 3840 -H 2160 -O HDMI-A-1 -e -- steam";
        type = "Application";
      };
    };
  };
  home.packages = with pkgs; [
    steam-with-pkgs
    gamescope
    steam-session
    mangohud
    protontricks
  ];
  home.persistence = {
    "/persist/home/lukasz" = {
      allowOther = true;
      directories = [
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
        # ".local/share/Steam"
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
      ];
    };
  };
}

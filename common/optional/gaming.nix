{ pkgs, ... }:
{
  # programs.gamemode = {
  #   enable = true;
  # };
  programs = {
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
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
          ];
      };
      gamescopeSession.enable = true;
    };
    gamescope.enable = true;
    gamescope.capSysNice = false; # Breaks gamescope in steam
  };

  environment.systemPackages = with pkgs; [ mangohud ];
}

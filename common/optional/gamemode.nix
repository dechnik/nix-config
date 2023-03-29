{
  config,
  pkgs,
  lib,
  ...
}: let

  startscript = pkgs.writeShellScript "gamemode-start" ''
    ${pkgs.procps}/bin/pkill swayidle
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
  '';
in {
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "on";
        inhibit_screensaver = 1;
      };
      custom = {
        start = startscript.outPath;
        end = endscript.outPath;
      };
    };
  };
}

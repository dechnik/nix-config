{ pkgs, lib, outputs, ... }:
{
  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    # xdg-utils-spawn-terminal
    # lyrics
  ];
}

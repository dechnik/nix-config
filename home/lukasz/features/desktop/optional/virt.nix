{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spice
  ];
}

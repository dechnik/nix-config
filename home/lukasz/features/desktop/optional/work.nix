{
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    remmina
    slack
  ];
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}

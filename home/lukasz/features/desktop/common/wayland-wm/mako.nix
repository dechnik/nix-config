{ config, ... }:
let
  inherit (config.colorscheme) palette variant;
in
{
  services.mako = {
    enable = true;
    iconPath = "${config.gtk.iconTheme.package}/share/icons/Gruvbox-Plus-Dark";
    font = "${config.fontProfiles.regular.name} ${toString config.fontProfiles.regular.size}";
    padding = "10,20";
    anchor = "top-right";
    width = 400;
    height = 150;
    borderSize = 2;
    defaultTimeout = 12000;
    backgroundColor = "#${palette.base00}dd";
    borderColor = "#${palette.base03}dd";
    textColor = "#${palette.base05}dd";
  };
}

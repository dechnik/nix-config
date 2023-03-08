{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "00c1862817d64c12a8e4c29a2d7b5c1be5619c592b6250c5"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = true;
    advertiseRoutes = [ ];
    tags = ["tag:oracle" "tag:server"];
  }

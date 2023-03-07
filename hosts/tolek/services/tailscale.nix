{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "2991f8f3461795510558e2bfa44f346bb7fc6aeb668dcfb1"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = true;
    advertiseRoutes = [ ];
    tags = ["tag:oracle" "tag:server"];
  }

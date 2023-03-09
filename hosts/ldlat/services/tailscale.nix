{
  config,
  pkgs,
  lib,
  ...
}:(import ../../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "f2e7125033de4fb3307e27909ec01fbbfd11e20397fd3af4"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = false;
    advertiseRoutes = [ ];
    tags = ["tag:work" "tag:desktop"];
  }

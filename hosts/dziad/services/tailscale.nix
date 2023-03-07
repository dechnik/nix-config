{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "7a82166697b0c2298b7cd15626f789f40263d6d03bb33b87"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = false;
    advertiseRoutes = [ ];
    tags = ["tag:home" "tag:work" "tag:desktop"];
  }

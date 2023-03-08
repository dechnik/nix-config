{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "1ed92e5bad2628077b97d56482e48916aff9043f7c246188"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = true;
    advertiseRoutes = [ ];
    tags = ["tag:hetzner" "tag:server"];
  }

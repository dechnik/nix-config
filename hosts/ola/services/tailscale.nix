{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "2ca1a07615758a089b515b8743ed4bf6433734ba83921d95"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = true;
    advertiseRoutes = [ ];
    tags = ["tag:hetzner" "tag:server"];
  }

{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "16652c590d3c2815a9b3e21333f4d715ef60e9591a4ae5cb"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = false;
    advertiseRoutes = [ ];
    tags = ["tag:pve" "tag:server" "tag:desktop"];
  }

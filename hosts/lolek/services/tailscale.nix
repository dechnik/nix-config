{
  config,
  pkgs,
  lib,
  ...
}:(import ../../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "952a5ba962100c02e4763b55640f1a925d091e7790aa1219"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = false;
    advertiseRoutes = [ ];
    tags = ["tag:pve" "tag:server"];
  }

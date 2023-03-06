{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "b2e52bc0373411481e6bc568af3435b5545bdcb2af3b5160"; # onetime key
    reauth = false;
    exitNode = true;
    advertiseRoutes = [ ];
    tags = ["tag:pve" "tag:server"];
  }

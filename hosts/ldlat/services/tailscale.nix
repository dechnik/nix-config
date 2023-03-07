{
  config,
  pkgs,
  lib,
  ...
}:(import ../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "69b6786a53ecf724ce1ac16254397e454c71518b2c664d9e"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = false;
    advertiseRoutes = [ ];
    tags = ["tag:work" "tag:desktop"];
  }

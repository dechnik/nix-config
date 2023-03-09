{
  config,
  pkgs,
  lib,
  ...
}:(import ../../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "7502c12583d639a03c53cd4d439cd2bbaf5f69c9ff46fa05"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = false;
    advertiseRoutes = [ ];
    tags = ["tag:home" "tag:work" "tag:desktop"];
  }

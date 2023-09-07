{ config
, pkgs
, lib
, ...
}: (import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale
{
  preAuthKey = "203af9bcd7293576d57b4550127880fcaad93aff1cd2a0ab"; # onetime key
  loginServer = "https://tailscale.dechnik.net";
  reauth = true;
  exitNode = false;
  advertiseRoutes = [ ];
  tags = [ "tag:home" "tag:work" "tag:desktop" ];
}

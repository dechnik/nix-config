{ config
, pkgs
, lib
, ...
}: (import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale
{
  preAuthKey = "6ff8fddf01e0bd77cd5ed13b48aa004767f217b4aeea7379"; # onetime key
  loginServer = "https://tailscale.dechnik.net";
  reauth = false;
  exitNode = false;
  advertiseRoutes = [ ];
  tags = [ "tag:pve" "tag:server" "tag:runner" ];
}

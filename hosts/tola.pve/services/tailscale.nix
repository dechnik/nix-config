{ config
, pkgs
, lib
, ...
}: (import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale
{
  preAuthKey = "af64e1095ebb7ee3a718610d8c1046ae605679bae6c4d4fa"; # onetime key
  loginServer = "https://tailscale.dechnik.net";
  reauth = false;
  exitNode = false;
  advertiseRoutes = [ ];
  tags = [ "tag:pve" "tag:server" "tag:desktop" ];
}

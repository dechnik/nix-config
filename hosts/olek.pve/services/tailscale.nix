{ config
, pkgs
, lib
, ...
}: (import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale
{
  preAuthKey = "50a661ec7920fc4b16b07e5df3a12d3144ba7d2a64e3fbd1"; # onetime key
  loginServer = "https://tailscale.dechnik.net";
  reauth = false;
  exitNode = false;
  advertiseRoutes = [ ];
  tags = [ "tag:pve" "tag:server" "tag:desktop" ];
}

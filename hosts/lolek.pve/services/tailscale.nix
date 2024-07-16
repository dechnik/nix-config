{ config
, pkgs
, lib
, ...
}: (import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale
{
  reauth = false;
  exitNode = false;
  tags = [ "tag:pve" "tag:server" ];
}

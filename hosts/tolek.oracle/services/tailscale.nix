{ config
, pkgs
, lib
, ...
}: let
  wireguardHosts = import ../../../metadata/wireguard.nix;
  wireguardConfig = wireguardHosts.servers.oracle;
in
  (import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale
  {
    reauth = false;
    exitNode = true;
    advertiseRoutes = wireguardConfig.additional_networks;
    tags = [ "tag:oracle" "tag:server" ];
  }

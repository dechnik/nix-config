{ config
, lib
, pkgs
, ...
}:
let
  wireguard = import ../../../common/functions/wireguard.nix { inherit config lib; };
in
wireguard.clientService "ldlat" "wireguard-ldlat"

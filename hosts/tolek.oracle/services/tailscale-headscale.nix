{
  config,
  pkgs,
  lib,
  ...
}:
(import ../../../common/functions/tailscale-headscale.nix { inherit config pkgs lib; }).tailscale {
  reauth = false;
  tags = [
    "tag:oracle"
    "tag:server"
  ];
}

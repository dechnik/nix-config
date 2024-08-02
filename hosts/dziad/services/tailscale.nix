{
  config,
  pkgs,
  lib,
  ...
}:
(import ../../../common/functions/tailscale.nix { inherit config pkgs lib; }).tailscale {
  reauth = false;
  exitNode = false;
  tags = [
    "tag:home"
    "tag:work"
    "tag:desktop"
  ];
}

{ pkgs, lib, inputs, config, ... }:
let
  traefik = import ../../../common/functions/traefik.nix { inherit config lib pkgs; };
in
{ } // (traefik.traefik {
  site = "oracle";
})

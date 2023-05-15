{ pkgs, lib, inputs, config, ... }:
let
  traefik = import ../../../common/functions/traefik.nix { inherit config lib pkgs; };
in
lib.mkMerge [
  {
    services.authelia.instances.main.settings.access_control.rules = [
      { domain = "traefik.oracle.dechnik.net"; subject = [ "group:admin" ]; policy = "one_factor"; }
    ];
  }

  (traefik.traefik { site = "oracle"; })
]

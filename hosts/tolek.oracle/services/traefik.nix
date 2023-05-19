{ pkgs, lib, inputs, config, ... }:
let
  traefik = import ../../../common/functions/traefik.nix { inherit config lib pkgs; };
in
lib.mkMerge [
  {
    services.traefik.dynamicConfigOptions.http = {
      serversTransports = {
        insecure-skip-verify.insecureSkipVerify = true;
      };

      routers.dashboard = {
        rule = "Host(`traefik.oracle.dechnik.net`) ";
        service = "api@internal";
        entryPoints = [ "web" ];
        middlewares = [ "dechnik-ips" "auth" ];
      };
    };

    services.authelia.instances.main.settings.access_control.rules = [
      { domain = "traefik.oracle.dechnik.net"; subject = [ "group:admin" ]; policy = "one_factor"; }
      { domain = "traefik.hetzner.dechnik.net"; subject = [ "group:admin" ]; policy = "one_factor"; }
      { domain = "traefik.pve.dechnik.net"; subject = [ "group:admin" ]; policy = "one_factor"; }
    ];
  }

  (traefik.traefik { site = "oracle"; })
]

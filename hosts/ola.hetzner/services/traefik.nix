{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  traefik = import ../../../common/functions/traefik.nix { inherit config lib pkgs; };
in
lib.mkMerge [
  {
    services.traefik.dynamicConfigOptions.http = {
      serversTransports = {
        insecure-skip-verify.insecureSkipVerify = true;
      };
      services = {
        mail = {
          loadBalancer.servers = [ { url = "http://127.0.0.1:8080"; } ];
        };
      };

      routers = {
        mail = {
          rule = "Host(`roundcube.dechnik.net`)";
          service = "mail";
          entryPoints = [ "web" ];
        };
        dashboard = {
          rule = "Host(`traefik.hetzner.dechnik.net`) ";
          service = "api@internal";
          entryPoints = [ "web" ];
          middlewares = [
            "dechnik-ips"
            "auth"
          ];
        };
      };
    };
  }

  (traefik.traefik { site = "hetzner"; })
]

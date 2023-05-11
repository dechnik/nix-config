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
        middlewares = [ "tailscale-ips" "auth" ];
      };

      middlewares.tailscale-ips = {
        ipWhiteList.sourceRange = [ "100.64.0.0/10" "fd7a:115c:a1e0::/48" ];
      };
      middlewares.wireguard-ips = {
        ipWhiteList.sourceRange = [ "10.60.0.0/24" "10.61.0.0/24" "10.62.0.0/24" ];
      };
    };

    services.authelia.instances.main.settings.access_control.rules = [
      { domain = "traefik.oracle.dechnik.net"; subject = [ "group:admin" ]; policy = "one_factor"; }
    ];
  }

  (traefik.traefik {site = "oracle";})
]

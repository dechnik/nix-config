{ lib, config, ... }:
let
  consul = import ../../../common/functions/consul.nix { inherit lib; };

  domain = "restic.${config.networking.domain}";
  port = 56899;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "/storage/restic";
    prometheus = true;
    listenAddress = "${toString port}";
    extraFlags = [ "--no-auth" ];
  };
  services.traefik.dynamicConfigOptions.http = {
    services.restic = {
      loadBalancer.servers = [ { url = "http://127.0.0.1:${toString port}"; } ];
    };

    routers.restic = {
      rule = "Host(`${domain}`)";
      service = "restic";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };

  my.consulServices.restic_server = consul.prometheusExporter "rest-server" port;
}

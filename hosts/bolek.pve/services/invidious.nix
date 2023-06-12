{ config, lib, ... }:
{
  services.traefik.dynamicConfigOptions.http = {
    services.yt = {
      loadBalancer.servers = [{ url = "http://10.60.0.2:3000"; }];
    };

    routers.yt = {
      rule = "Host(`yt.pve.dechnik.net`)";
      service = "yt";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };
}

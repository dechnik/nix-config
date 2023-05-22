{ config, lib, ... }:
{
  services.traefik.dynamicConfigOptions.http = {
    services.jf = {
      loadBalancer.servers = [{ url = "http://10.60.0.2:8096"; }];
    };

    routers.jf = {
      rule = "Host(`jf.dechnik.net`)";
      service = "jf";
      entryPoints = [ "web" ];
    };
  };
}

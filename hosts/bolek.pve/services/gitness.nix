{ config, inputs, ... }:
{
  services = {
    traefik.dynamicConfigOptions.http = {
      services.gitness = {
        loadBalancer.servers = [ { url = "http://10.60.0.3:3088"; } ];
      };

      routers.gitness = {
        rule = "Host(`gitness.dechnik.net`)";
        service = "gitness";
        entryPoints = [ "web" ];
      };
    };
  };
}

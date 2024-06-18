{config,...}:
{
  services.atuin = {
    enable = true;
    openRegistration = true;
    port = 8888;
    host = "10.61.0.1";
  };
  services.traefik.dynamicConfigOptions.http = {
    services.atuin = {
      loadBalancer.servers = [{ url = "http://${config.services.atuin.host}:${toString config.services.atuin.port}"; }];
    };

    routers.atuin = {
      rule = "Host(`atuin.dechnik.net`)";
      service = "atuin";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };
}

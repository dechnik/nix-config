let
  domain = "files.dechnik.net";
in
{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      static-files = {
        autoStart = true;
        image = "nginx:latest";
        ports = [ "50000:80" ];
        volumes = [ "/srv/files:/usr/share/nginx/html:ro" ];
      };
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.static-files = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:50000"; }];
    };

    routers.static-files = {
      rule = "Host(`${domain}`)";
      service = "static-files";
      entryPoints = [ "web" ];
    };
  };
}

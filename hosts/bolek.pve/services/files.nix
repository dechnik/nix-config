{
  pkgs,
  ...
}:
let
  domain = "files.dechnik.net";
  default-conf = pkgs.writeText "default.conf" ''
    server {
        listen       80;
        listen  [::]:80;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            autoindex on;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
  '';
in
{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      static-files = {
        autoStart = true;
        image = "nginx:latest";
        ports = [ "50000:80" ];
        volumes = [
          "/srv/files:/usr/share/nginx/html:ro"
          "${default-conf}:/etc/nginx/conf.d/default.conf"
        ];
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

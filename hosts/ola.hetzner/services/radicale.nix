{ pkgs
, lib
, config
, ...
}:
let
  domain = "dav.dechnik.net";
  port = "5232";
in
{
  environment.persistence = {
    "/persist".directories = [
      "/var/lib/radicale"
    ];
  };

  sops.secrets.radicale-htpasswd = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.radicale.name;
    group = config.users.users.radicale.group;
  };
  services = {
    radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "127.0.0.1:${port}" "::1:${port}" ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets.radicale-htpasswd.path;
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };
      };
    };
    traefik.dynamicConfigOptions.http = {
      services.dav = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:${port}"; }];
      };

      routers.dav = {
        rule = "Host(`${domain}`)";
        service = "dav";
        entryPoints = [ "web" ];
      };
    };
  };
}

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

  security.acme.certs."${domain}".domain = domain;
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
    nginx.virtualHosts = {
      "${domain}" = {
        forceSSL = true;
        useACMEHost = "${domain}";
        locations."/".proxyPass = "http://localhost:${port}";
        extraConfig = ''
          proxy_set_header  X-Script-Name /;
          proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass_header Authorization;
        '';
      };
    };
  };
}

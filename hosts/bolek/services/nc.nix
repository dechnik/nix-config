{ pkgs, config, ... }:
let
  hostName = "nextcloud.dechnik.net";
in
{
  security.acme.certs = {
    "nc.dechnik.net" = {
      group = "nginx";
    };
    "nextcloud.dechnik.net" = {
      group = "nginx";
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };

  services = {
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud25;
      enable = true;
      https = true;
      enableBrokenCiphersForSSE = false;
      home = "/media/nextcloud";
      config = {
        trustedProxies = ["10.30.10.12"];
        adminuser = "root";
        adminpassFile = config.sops.secrets.nextcloud-password.path;
        overwriteProtocol = "https";
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        defaultPhoneRegion = "PL";
      };
      extraOptions = {
        bulkupload.enabled = false;
      };
    };
    postgresql = {
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "DATABASE nextcloud" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "nextcloud" ];
    };
    nginx.virtualHosts."nextcloud.dechnik.net" = {
      forceSSL = true;
      useACMEHost = "nextcloud.dechnik.net";
    };
    nginx.virtualHosts."nc.dechnik.net" = {
      forceSSL = true;
      # enableACME = true;
      useACMEHost = "nc.dechnik.net";
      extraConfig = ''
        client_max_body_size 0;
        underscores_in_headers on;
        access_log /var/log/nginx/nc.dechnik.net.access.log;
      '';
      locations = {
        "/" = {
          extraConfig = ''
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            add_header Front-End-Https on;
            proxy_pass http://10.30.10.9:80;
          '';
        };
        "/.well-known/carddav" = {
          return = "301 $scheme://$host/remote.php/dav";
        };
        "/.well-known/caldav" = {
          return = "301 $scheme://$host/remote.php/dav";
        };
        "/robots.txt" = {
          extraConfig = ''
            allow all;
            log_not_found off;
            access_log off;
          '';
        };
      };
    };
  };
}

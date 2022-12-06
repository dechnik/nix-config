{ config, ... }:
{
  security.acme.certs = {
    "nc.dechnik.net" = {
    };
  };
  services = {
    nginx.virtualHosts."nc.dechnik.net" = {
      forceSSL = true;
      # enableACME = true;
      useACMEHost = "nc.dechnik.net";
      extraConfig = ''
        client_max_body_size 0;
        underscores_in_headers on;
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

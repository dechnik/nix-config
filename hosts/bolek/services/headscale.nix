{ config, lib, ... }:
{
  security.acme.certs = {
    "tailscale.dechnik.net" = {
      group = "nginx";
    };
  };
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      dns = {
        baseDomain = "dechnik.net";
        magicDns = true;
        domains = [ "ts.dechnik.net" ];
        nameservers = [
          "9.9.9.9"
        ];
      };
      port = 8085;
      serverUrl = "https://tailscale.dechnik.net";
      settings = {
        logtail.enabled = false;
        log.level = "warn";
      };
    };

    nginx.virtualHosts = {
      "tailscale.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "tailscale.dechnik.net";
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $server_name;
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
            add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
          '';
        };
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/headscale" ];
  };
}

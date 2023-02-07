{ config, lib, ... }:
{
  security.acme.certs = {
    "tailscale.dechnik.net" = {
      group = "nginx";
    };
  };
  networking.firewall.allowedUDPPorts = [3478];
  services = {
    headscale = {
      enable = true;
      settings = {
        dns_config = {
          override_local_dns = true;
          baseDomain = "dechnik.net";
          magicDns = true;
          domains = [ "ts.dechnik.net" ];
          nameservers = [
            "9.9.9.9"
          ];
        };
        serverUrl = "https://tailscale.dechnik.net";
        ip_prefixes = [
          "10.100.0.0/16"
        ];
        logtail.enabled = false;
        log.level = "warn";
      };
      port = 8085;
    };

    nginx.virtualHosts = {
      "tailscale.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "tailscale.dechnik.net";
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
            extraConfig = ''
              keepalive_requests          100000;
              keepalive_timeout           160s;
              proxy_buffering             off;
              proxy_connect_timeout       75;
              proxy_ignore_client_abort   on;
              proxy_read_timeout          900s;
              proxy_send_timeout          600;
              send_timeout                600;
            '';
          };
          "/metrics" = {
            proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
            extraConfig = ''
              allow 10.0.0.0/8;
              deny all;
            '';
          };
        };
        extraConfig = ''
          access_log /var/log/nginx/tailscale.dechnik.net.access.log;
        '';
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/headscale" ];
  };
}

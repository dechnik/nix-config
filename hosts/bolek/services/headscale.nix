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
      port = 8085;
      address = "127.0.0.1";
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
        metrics_listen_addr = "127.0.0.1:8095";
        ip_prefixes = [
          "10.100.0.0/16"
        ];
        logtail.enabled = false;
        log.level = "warn";
      };
    };

    nginx.virtualHosts = {
      "tailscale.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "tailscale.dechnik.net";
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
          "/metrics" = {
            proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
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

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
        ip_prefixes = [
          "10.100.10.0/10"
        ];
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

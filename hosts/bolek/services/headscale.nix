{ config, lib, ... }:
{
  services = {
    acme.certs = {
      "tailscale.dechnik.net" = {
        group = "nginx";
      };
    };
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
        };
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/headscale" ];
  };
}

{ config, lib, pkgs, ... }:
let
  rssport = 49999;
in
{
  security.acme.certs = {
    "rss.dechnik.net" = {
      group = "nginx";
    };
  };
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      full-text-rss = {
        autoStart = true;
        image = "heussd/fivefilters-full-text-rss:latest";
        ports = [ "50000:80" ];
      };
      freshrss = {
        autoStart = true;
        image = "lscr.io/linuxserver/freshrss:latest";
        ports = [ "${toString rssport}:80" ];
        environment = {
          "TZ" = "Europe/Warsaw";
        };
        volumes = [ "/var/lib/freshrss:/config" ];
      };
    };
  };
  services.nginx.virtualHosts = {
    "rss.dechnik.net" = {
      forceSSL = true;
      useACMEHost = "rss.dechnik.net";
      locations."/" = {
        proxyPass = "http://localhost:${toString rssport}";
      };
      extraConfig = ''
        access_log /var/log/nginx/rss.dechnik.net.access.log;
      '';
    };
  };
  environment.persistence = {
    "/persist".directories = [ "/var/lib/freshrss" ];
  };
}

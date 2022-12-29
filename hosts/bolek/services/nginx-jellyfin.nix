{ config, lib, ... }:
{
  security.acme.certs = {
    "jf.dechnik.net" = {
      group = "nginx";
    };
  };
  services = {
    nginx.virtualHosts = {
      "jf.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "jf.dechnik.net";
        locations."/" = {
          proxyPass = "http://10.30.10.14:8096";
        };
        extraConfig = ''
          access_log /var/log/nginx/jf.dechnik.net.access.log;
        '';
      };
    };
  };
}

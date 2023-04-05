let
  domain = "files.dechnik.net";
in
{
  security.acme.certs."${domain}".domain = domain;

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = domain;
    locations."/" = {
      root = "/srv/files";
      extraConfig = ''
        autoindex on;
      '';
    };
    extraConfig = ''
      access_log /var/log/nginx/${domain}.access.log;
    '';
  };
}

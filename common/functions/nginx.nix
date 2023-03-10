{
  config,
  lib,
}: let
  internalVhost = {
    domain,
    proxyPass,
    proxyWebsockets ? true,
    allowLocal ? true,
    locationExtraConfig ? "",
  }: {
    security.acme.certs."${domain}".domain = domain;

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        inherit proxyPass;
        inherit proxyWebsockets;
        extraConfig =
          ""
          + lib.optionalString allowLocal ''
            allow 10.0.0.0/8;
            satisfy any;
          ''
          + locationExtraConfig;
      };
      extraConfig =
        ''
          access_log /var/log/nginx/${domain}.access.log;
        '';
    };
  };

  externalVhost = {
    domain,
    proxyPass,
    proxyWebsockets ? true,
  }: {
    security.acme.certs."${domain}".domain = domain;

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        inherit proxyPass;
        inherit proxyWebsockets;
      };
      extraConfig = ''
        access_log /var/log/nginx/${domain}.access.log;
      '';
    };
  };
in {
  inherit internalVhost;
  inherit externalVhost;
}
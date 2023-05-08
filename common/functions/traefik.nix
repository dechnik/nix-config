{ config
, lib
, pkgs
,
}:
with lib; let
  traefik =
    { hostname ? ''${builtins.replaceStrings [".dechnik.net"] [""] config.networking.fqdn}''
    , site
    , persist ? true
    ,
    }: {
      environment.persistence = lib.mkIf persist {
        "/persist".directories = [ "/var/lib/traefik" ];
      };

      sops.secrets."traefik-config.json" = {
        sopsFile = ../../hosts/${hostname}/secrets.yaml;
        owner = config.users.users.traefik.name;
      };

      systemd.services.traefik = {
        serviceConfig.EnvironmentFile = config.security.acme.defaults.credentialsFile;
      };

      services.traefik.enable = true;

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      services.traefik.staticConfigFile = "/var/lib/traefik/config.yml";

      systemd.services.traefik.preStart = ''
        ${pkgs.jq}/bin/jq --slurp '.[0] * .[1]' \
          ${pkgs.writeText "config.json" (builtins.toJSON config.services.traefik.staticConfigOptions)} \
          ${config.sops.secrets."traefik-config.json".path} \
          > ${config.services.traefik.staticConfigFile}
      '';

      services.traefik.staticConfigOptions = {
        providers.file.filename =
          pkgs.writeText "config.yml" (builtins.toJSON config.services.traefik.dynamicConfigOptions);

        api.dashboard = true;
        accessLog = { };

        serversTransport.insecureSkipVerify = true;

        entryPoints.web = {
          address = ":443";
          http.tls = {
            certResolver = "acme";
            domains = [
              {
                main = "dechnik.net";
                sans = [ "*.dechnik.net" "*.${site}.dechnik.net" ];
              }
            ];
          };
        };

        entryPoints.web-insecure = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "web";
            scheme = "https";
          };
        };

        certificatesResolvers.acme.acme = {
          email = config.security.acme.defaults.email;
          keyType = toUpper config.security.acme.defaults.keyType;
          dnsChallenge.provider = config.security.acme.defaults.dnsProvider;
          storage = "/var/lib/traefik/acme.json";
        };
      };

      users.users.traefik.extraGroups = [ "acme" ];
    };
in
{ inherit traefik; }

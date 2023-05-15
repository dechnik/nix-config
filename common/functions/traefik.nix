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
        serviceConfig = {
          EnvironmentFile = config.security.acme.defaults.credentialsFile;
          WorkingDirectory = "/var/lib/traefik";
        };
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

        experimental.plugins.traefik-plugin-query-modification = {
          moduleName = "github.com/kingjan1999/traefik-plugin-query-modification";
          version = "v1.0.0";
        };

        certificatesResolvers.acme.acme = {
          email = config.security.acme.defaults.email;
          keyType = toUpper config.security.acme.defaults.keyType;
          dnsChallenge.provider = config.security.acme.defaults.dnsProvider;
          storage = "/var/lib/traefik/acme.json";
        };
      };

      services.traefik.dynamicConfigOptions.http = {
        serversTransports = {
          insecure-skip-verify.insecureSkipVerify = true;
        };

        routers.dashboard = {
          rule = "Host(`traefik.${site}.dechnik.net`) ";
          service = "api@internal";
          entryPoints = [ "web" ];
          middlewares = [ "dechnik-ips" "auth" ];
        };

        middlewares.auth = {
          forwardAuth = {
            address = "http://auth.dechnik.net/api/verify?rd=https%3A%2F%2Fauth.dechnik.net%2F";
            trustForwardHeader = true;
            authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
          };
        };

        middlewares.dechnik-ips = {
          ipWhiteList.sourceRange = [
            "100.64.0.0/10"
            "10.69.0.0/24"
            "10.60.0.0/24"
            "10.61.0.0/24"
            "10.62.0.0/24"
            "fd7a:115c:a1e0::/48"
          ];
        };
      };


      users.users.traefik.extraGroups = [ "acme" ];
    };
in
{ inherit traefik; }

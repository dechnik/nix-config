{ lib, config, pkgs, ... }:
let
  consul = import ../../../common/functions/consul.nix { inherit lib; };
  serverName = "dechnik.net";
  clientConfig = {
    "m.homeserver".base_url = "https://matrix.${serverName}";
    "m.identity_server" = { };
  };
  serverConfig."m.server" = "${config.services.matrix-synapse.settings.server_name}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  environment.persistence = {
    "/persist".directories = [
      "/var/lib/matrix-synapse"
    ];
  };

  sops.secrets = {
    matrix-synapse = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
      sopsFile = ../secrets.yaml;
    };
  };
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';
  environment.systemPackages = [ pkgs.matrix-synapse ];
  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

    extraConfigFiles = [
      config.sops.secrets.matrix-synapse.path
    ];
    plugins = with config.services.matrix-synapse.package.plugins; [
      matrix-synapse-ldap3
    ];
    settings = {
      server_name = serverName;
      public_baseurl = "https://matrix.dechnik.net";
      enable_metrics = true;
      enable_registration = false;
      # trust the default key server matrix.org
      suppress_key_server_warning = true;
      email = {
        smtp_host = "localhost";
        smtp_port = 25;
        enable_tls = false;
        notif_from = "matrix <monitoring@dechnik.net>";
        client_base_url = "https://chat.dechnik.net/";
        app_name = "matrix";
        enable_notifs = true;
      };

      max_upload_size = "100M";

      listeners = [
        # Federation
        {
          bind_addresses = [ "127.0.0.1" ];
          port = 8008;
          tls = false;
          x_forwarded = true;
          type = "http";
          resources = [ { names = [ "client" "federation" ]; compress = false; } ];
        }

        {
          bind_addresses = [ "127.0.0.1" ];
          port = 9191;
          type = "metrics";
          tls = false;
          resources = [ ];
        }
      ];
    };
  };

  # my.consulServices.matrix-synapse = consul.prometheusExporter "matrix-synapse" 9191;

  services.traefik.dynamicConfigOptions.http = {
    services = {
      matrix = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:8008"; }];
      };
      matrix-admin = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:8080"; }];
      };
      element = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:8080"; }];
      };
    };

    routers = {
      matrix = {
        rule = "(Host(`matrix.dechnik.net`) && (PathPrefix(`/_matrix`) || PathPrefix(`/_synapse`))) || (Host(`dechnik.net`) && (PathPrefix(`/_matrix`) || PathPrefix(`/_synapse`)))";
        service = "matrix";
        entryPoints = [ "web" ];
      };
      matrix-admin = {
        rule = "Host(`admin.chat.dechnik.net`)";
        service = "matrix-admin";
        entryPoints = [ "web" ];
        middlewares = [ "dechnik-ips" ];
      };
      element = {
        rule = "Host(`chat.dechnik.net`)";
        service = "element";
        entryPoints = [ "web" ];
      };
      matrix-wellknown = {
        rule = "(Host(`dechnik.net`) && PathPrefix(`/.well-known/matrix`))";
        service = "element";
        entryPoints = [ "web" ];
      };
    };
  };
  services.nginx = {
    enable = true;
    defaultHTTPListenPort = 8080;
    virtualHosts = {
      "${serverName}" = {
        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      };
      "chat.${serverName}" = {
        root = pkgs.element-web.override {
          conf = {
            default_server_config = {
              "m.homeserver" = {
                base_url = "https://matrix.${serverName}";
                server_name = serverName;
              };
            };
          };
        };
      };
      "admin.chat.${serverName}" = {
        locations."/" = {
          root = pkgs.synapse-admin;
        };
      };
    };
  };
}

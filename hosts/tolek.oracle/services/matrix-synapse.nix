{ lib, config, pkgs, ... }:
let
  consul = import ../../../common/functions/consul.nix { inherit lib; };
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
      server_name = "dechnik.net";
      public_baseurl = "https://matrix.dechnik.net";
      enable_metrics = true;
      enable_registration = false;
      # trust the default key server matrix.org
      suppress_key_server_warning = true;

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
    services.matrix = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:8008"; }];
    };

    routers.matrix = {
      rule = "Host(`matrix.dechnik.net`) && (PathPrefix(`/_matrix`) || PathPrefix(`/_synapse`))";
      service = "matrix";
      entryPoints = [ "web" ];
    };
  };
}

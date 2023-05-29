{ config, pkgs, ... }:
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
  environment.systemPackages = [ pkgs.matrix-synapse ];
  services.matrix-synapse = {
    enable = true;

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

      max_upload_size = "100M";

      listeners = [
        # Federation
        {
          bind_addresses = [ "127.0.0.1" ];
          port = 11338;
          tls = false;
          x_forwarded = true;
          resources = [ { names = [ "federation" ]; compress = false; } ];
        }

        # Client
        {
          bind_addresses = [ "127.0.0.1" ];
          port = 11339;
          tls = false;
          x_forwarded = true;
          resources = [ { names = [ "client" ]; compress = false; } ];
        }
        {
          bind_addresses = [ "10.61.0.1" ];
          port = 9191;
          type = "metrics";
          tls = false;
          resources = [ ];
        }
      ];
    };
  };

  # services.traefik.dynamicConfigOptions.http = {
  #   services.lldap = {
  #     loadBalancer.servers = [{ url = "http://127.0.0.1:17170"; }];
  #   };

  #   routers.lldap = {
  #     rule = "Host(`ldap.dechnik.net`)";
  #     service = "lldap";
  #     entryPoints = [ "web" ];
  #     middlewares = [ "dechnik-ips" ];
  #   };
  # };
}

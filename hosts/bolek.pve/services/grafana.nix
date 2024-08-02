{
  pkgs,
  lib,
  config,
  ...
}:
let
  domain = "grafana.${config.networking.domain}";
in
{
  environment.persistence = {
    "/persist".directories = [ "/var/lib/grafana" ];
  };
  sops.secrets = {
    grafana-admin = {
      sopsFile = ../secrets.yaml;
      owner = "grafana";
      mode = "0400";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    services.grafana = {
      loadBalancer.servers = [
        {
          url = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        }
      ];
    };

    routers.grafana = {
      rule = "Host(`${domain}`)";
      service = "grafana";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        inherit domain;
        root_url = "https://${domain}";
        http_port = 3300;
        enforce_domain = true;
        enable_gzip = true;
        http_addr = "127.0.0.1";
      };

      analytics.reporting_enabled = false;

      auth = {
        anonymous_enabled = true;
        anonymous_org_name = "Main Org.";
        anonymous_org_role = "Viewer";
      };

      security.admin_password = "$__file{${config.sops.secrets.grafana-admin.path}}";

      smtp = {
        enabled = true;
        host = "localhost:25";
        from_address = "grafana@${config.networking.domain}";
      };
    };

    provision = {
      enable = true;
      datasources = {
        settings.datasources = [
          {
            url = "https://prometheus.${config.networking.domain}";
            name = "Prometheus";
            isDefault = true;
            type = "prometheus";
          }
          {
            url = "https://loki.${config.networking.domain}";
            name = "Loki";
            type = "loki";
          }
          {
            name = "Alertmanager";
            type = "alertmanager";
            url = "http://127.0.0.1:9093";
            jsonData = {
              implementation = "prometheus";
              handleGrafanaManagedAlerts = config.services.prometheus.enable;
            };
          }
        ];
      };
    };
  };
}

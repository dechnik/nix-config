{ pkgs
, lib
, config
, ...
}:
let
  nginx = import ../../../common/functions/nginx.nix { inherit config lib; };
  domain = "grafana.${config.networking.domain}";
in
lib.mkMerge [
  {
    environment.persistence = {
      "/persist".directories = [
        "/var/lib/grafana"
      ];
    };
    sops.secrets = {
      grafana-admin = {
        sopsFile = ../secrets.yaml;
        owner = "grafana";
        mode = "0400";
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
          ];
        };
      };
    };
  }

  (nginx.internalVhost
    {
      inherit domain;

      tailscaleAuth = false;
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";

      locationExtraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
      '';
    })
]

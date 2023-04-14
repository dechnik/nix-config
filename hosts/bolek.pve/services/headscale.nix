{ pkgs, config, lib, ... }:
let
  webuiport = 5050;
in
{
  sops.secrets = {
    headscale-private-key = {
      sopsFile = ../secrets.yaml;
      owner = "headscale";
      mode = "0600";
    };
    headscale-noise-key = {
      sopsFile = ../secrets.yaml;
      owner = "headscale";
      mode = "0600";
    };
    headscale-oidc-secret = {
      sopsFile = ../secrets.yaml;
      owner = "headscale";
      mode = "0600";
    };
    headscale-acl = {
      sopsFile = ../secrets.yaml;
      owner = "headscale";
      mode = "0600";
    };
    headscale-webui-env = {
      sopsFile = ../secrets.yaml;
    };
  };
  security.acme.certs = {
    "tailscale.dechnik.net" = {
      group = "nginx";
    };
  };
  networking.firewall.allowedUDPPorts = [ 3478 ];
  networking.firewall.allowedTCPPorts = [ 50443 ];
  systemd.services.headscale.environment = {
    # HEADSCALE_EXPERIMENTAL_FEATURE_SSH="1";
    # HEADSCALE_LOG_LEVEL = "trace";
    # GRPC_GO_LOG_VERBOSITY_LEVEL = "2";
    # GRPC_GO_LOG_SEVERITY_LEVEL = "info";
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      headscale-webui = {
        autoStart = true;
        image = "ghcr.io/ifargle/headscale-webui:latest";
        ports = [ "${toString webuiport}:5000" ];
        environment = {
          "TZ" = "Europe/Warsaw";
          "OIDC_AUTH_URL" = "https://nextcloud.dechnik.net/.well-known/openid-configuration";
          "OIDC_CLIENT_ID" = "oshNhpGPlmXuP0DA8Qz37xz3gXEbbbdKSTCjLEWw5vE5G9imq0cYh3HErtBxyVy8";
          "AUTH_TYPE" = "oidc";
          "SCRIPT_NAME" = "/admin";
          "DOMAIN_NAME" = "https://tailscale.dechnik.net";
          "HS_SERVER" = "https://tailscale.dechnik.net";
        };
        environmentFiles = [ "${config.sops.secrets.headscale-webui-env.path}" ];
        volumes = [
          "/var/lib/headscale-webui:/data"
          "/etc/static/headscale/:/etc/headscale/:ro"
        ];
      };
    };
  };
  services = {
    headscale = {
      enable = true;
      settings = {
        private_key_file = config.sops.secrets.headscale-private-key.path;
        noise = {
          private_key_path = config.sops.secrets.headscale-noise-key.path;
        };
        # acl_policy_path = config.sops.secrets.headscale-acl.path;
        acl_policy_path = "/var/lib/headscale/headscale-acl";
        dns_config = {
          override_local_dns = true;
          baseDomain = "dechnik.net";
        };
        derp = {
          server = {
            enabled = true;
            region_id = 999;
            region_code = "dechnik";
            region_name = "tailscale.dechnik.net";
            stun_listen_addr = "0.0.0.0:3478";
          };
        };
        server_url = "https://tailscale.dechnik.net";
        metrics_listen_addr = "127.0.0.1:8095";
        ip_prefixes = [
          "fd7a:115c:a1e0::/48"
          "100.64.0.0/10"
        ];
        grpc_listen_addr = "127.0.0.1:50443";
        grpc_allow_insecure = true;
        oidc = {
          issuer = "https://nextcloud.dechnik.net";
          client_id = "00EczQNvd5f3yL8XD4Ff5sI4Qrynmc7nMfX3lSEKE61jbCICbSc4XiWSnA3QCYRe";
          client_secret_file = config.sops.secrets.headscale-oidc-secret.path;

          domain_map = {
            ".*" = "dechnik.net";
          };
        };
      };
    };

    nginx.virtualHosts = {
      "tailscale.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "tailscale.dechnik.net";
        locations = {
          "/headscale." = {
            extraConfig = ''
              grpc_pass grpc://${config.services.headscale.settings.grpc_listen_addr};
            '';
            priority = 1;
          };
          "/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
            extraConfig = ''
              keepalive_requests          100000;
              keepalive_timeout           160s;
              proxy_buffering             off;
              proxy_connect_timeout       75;
              proxy_ignore_client_abort   on;
              proxy_read_timeout          900s;
              proxy_send_timeout          600;
              send_timeout                600;
            '';
          };
          "/admin" = {
            proxyPass = "http://localhost:${toString webuiport}/admin";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Host $server_name;
              proxy_buffering off;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
            '';
          };
          "/metrics" = {
            proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
            extraConfig = ''
              allow 10.0.0.0/8;
              allow 100.64.0.0/16;
              deny all;
            '';
            priority = 2;
          };
        };
        extraConfig = ''
          access_log /var/log/nginx/tailscale.dechnik.net.access.log;
        '';
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package pkgs.sqlite-interactive pkgs.sqlite-web ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/headscale"
      { directory = "/var/lib/headscale-webui"; user = "1000"; group = "1000"; }
    ];
  };
}

{
  pkgs,
  config,
  lib,
  ...
}:
let
  webuiport = 5050;
  cfg = config.services.headscale;
  settingsFormat = pkgs.formats.yaml { };
  hdConfigFile = settingsFormat.generate "headscale.yaml" cfg.settings;
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
    headscale-acl = {
      sopsFile = ../secrets.yaml;
      owner = "headscale";
      mode = "0600";
    };
    headscale-oidc-secret = {
      sopsFile = ../secrets.yaml;
      owner = "headscale";
      mode = "0600";
    };
    headscale-webui-env = {
      sopsFile = ../secrets.yaml;
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
          "OIDC_AUTH_URL" = "https://auth.dechnik.net/.well-known/openid-configuration";
          "OIDC_CLIENT_ID" = "headscale-webui";
          "SCRIPT_NAME" = "/admin";
          "DOMAIN_NAME" = "https://tailscale.dechnik.net";
          "HS_SERVER" = "https://tailscale.dechnik.net";
          "LOG_LEVEL" = "Debug";
        };
        environmentFiles = [ "${config.sops.secrets.headscale-webui-env.path}" ];
        volumes = [
          "/var/lib/headscale-webui:/data"
          "${hdConfigFile}:/etc/headscale/config.yaml:ro"
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
          issuer = "https://auth.dechnik.net";
          client_id = "headscale";
          client_secret_file = config.sops.secrets.headscale-oidc-secret.path;
          strip_email_domain = true;
        };
      };
    };
    traefik.dynamicConfigOptions.http = {
      services = {
        tailscale = {
          loadBalancer.servers = [ { url = "http://127.0.0.1:${toString config.services.headscale.port}"; } ];
        };
        tailscale-metrics = {
          loadBalancer.servers = [
            { url = "http://${toString config.services.headscale.settings.metrics_listen_addr}"; }
          ];
        };
        tailscale-web = {
          loadBalancer.servers = [ { url = "http://127.0.0.1:${toString webuiport}"; } ];
        };
      };

      routers = {
        tailscale = {
          rule = "(Host(`tailscale.dechnik.net`) && !PathPrefix(`/admin`))";
          service = "tailscale";
          entryPoints = [ "web" ];
        };
        tailscale-metrics = {
          rule = "(Host(`tailscale.pve.dechnik.net`) && PathPrefix(`/metrics`))";
          service = "tailscale-metrics";
          entryPoints = [ "web" ];
          middlewares = [ "dechnik-ips" ];
        };
        tailscale-web = {
          rule = "(Host(`tailscale.dechnik.net`) && PathPrefix(`/admin`))";
          service = "tailscale-web";
          entryPoints = [ "web" ];
          middlewares = [ "auth" ];
        };
      };
    };
  };

  environment.systemPackages = [
    config.services.headscale.package
    pkgs.sqlite-interactive
    pkgs.sqlite-web
  ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/headscale"
      {
        directory = "/var/lib/headscale-webui";
        user = "1000";
        group = "1000";
      }
    ];
  };
}

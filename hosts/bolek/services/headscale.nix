{ config, lib, ... }:
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
  };
  security.acme.certs = {
    "tailscale.dechnik.net" = {
      group = "nginx";
    };
  };
  networking.firewall.allowedUDPPorts = [ 3478 ];
  services = {
    headscale = {
      enable = true;
      port = 8085;
      address = "127.0.0.1";
      settings = {
        private_key_file = config.sops.secrets.headscale-private-key.path;
        noise = {
          private_key_path = config.sops.secrets.headscale-noise-key.path;
        };
        dns_config = {
          override_local_dns = true;
          baseDomain = "dechnik.net";
        };
        serverUrl = "https://tailscale.dechnik.net";
        metrics_listen_addr = "127.0.0.1:8095";
        ip_prefixes = [
          "fd7a:115c:a1e0::/48"
          "100.64.0.0/10"
        ];
        grpc_listen_addr = "127.0.0.1:50443";
        grpc_allow_insecure = true;
        derp = {
          server = {
            enabled = true;
            region_id = 999;
            region_code = "dechnik";
            region_name = "tailscale.dechnik.net";
            stun_listen_addr = "0.0.0.0:3478";
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
          "/metrics" = {
            proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
            extraConfig = ''
              allow 10.0.0.0/8;
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

  environment.systemPackages = [ config.services.headscale.package ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/headscale" ];
  };
}

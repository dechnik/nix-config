{ config
, lib
, ...
}:
with lib builtins; let
  domain = "consul.${config.networking.domain}";

  s = import ../../metadata/sites.nix { inherit lib config; };
  peers = s.consulPeers;
in
{
  imports = [ ./consul.nix ];
  config = lib.mkMerge [
    {
      services.consul = {
        enable = true;
        webUi = true;

        extraConfig = {
          server = true;
          bootstrap = true;

          bind_addr = ''{{ GetInterfaceIP "${config.my.lan}" }}'';

          retry_join = [ ];
          retry_join_wan = builtins.attrValues peers;

          connect = {
            enabled = true;
          };
        };
      };

      networking.firewall.allowedTCPPorts = [
        8500 # HTTP server
      ];

      services.traefik.dynamicConfigOptions.http = {
        services.consul = {
          loadBalancer.servers = [{ url = "http://127.0.0.1:8500"; }];
        };

        routers.consul = {
          rule = "Host(`${domain}`)";
          service = "consul";
          entryPoints = [ "web" ];
          middlewares = [ "tailscale-ips" ];
        };
      };
    }
  ];
}

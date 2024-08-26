{ pkgs, ... }:
{
  # services.weechat.enable = true;
  services.traefik.dynamicConfigOptions.http = {
    services = {
      wc = {
        loadBalancer.servers = [ { url = "http://127.0.0.1:8080"; } ];
      };
    };

    routers = {
      wc = {
        rule = "Host(`wc.dechnik.net`)";
        service = "wc";
        entryPoints = [ "web" ];
        middlewares = [ "dechnik-ips" ];
      };
    };
  };
  # services.pantalaimon-headless.instances.weechat = {
  #   listenPort = 20662;
  #   homeserver = "https://dechnik.net";
  #   ssl = false;
  # };
  services.nginx = {
    enable = true;
    defaultHTTPListenPort = 8080;
    virtualHosts = {
      "wc.dechnik.net" = {
        locations."^~ /weechat" = {
          proxyPass = "http://127.0.0.1:4242";
          proxyWebsockets = true;
        };
        locations."/" = {
          root = pkgs.glowing-bear;
        };
      };
    };
  };
}

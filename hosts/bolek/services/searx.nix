{ pkgs, config, ... }:
{
  security.acme.certs = {
    "sx.dechnik.net" = {
      group = "nginx";
    };
  };
  services = {
    searx = {
      enable = true;
      package = pkgs.searxng;
      environmentFile = config.sops.secrets.searx-env.path;
      runInUwsgi = true;
      settings = {
        server = {
          secret_key = "@SEARX_SECRET_KEY@";
          base_url = "https://sx.dechnik.net/";
        };
        ui = {
          static_use_hash = true;
          infinite_scroll = true;
          center_alignment = true;
          query_in_title = true;
        };
        enabled_plugins = [
          "Hash plugin"
          "Search on category select"
          "Tracker URL remover"
          "Vim-like hotkeys"
          "Hostname replace"
        ];
      };
    };
    nginx.virtualHosts."sx.dechnik.net" = {
      forceSSL = true;
      useACMEHost = "sx.dechnik.net";
      extraConfig = ''
        access_log /var/log/nginx/sx.dechnik.net.access.log;
      '';
      locations = {
        "/" = {
          extraConfig = ''
            include ${pkgs.nginx}/conf/uwsgi_params;
            uwsgi_pass unix:/run/searx/searx.sock;
          '';
        };
      };
    };
  };
  sops.secrets.searx-env = {
    owner = "searx";
    group = "searx";
    sopsFile = ../secrets.yaml;
  };
}

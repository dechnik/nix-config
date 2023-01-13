{ pkgs, config, ... }:
{
  security.acme.certs = {
    "sx.dechnik.net" = {
      group = "nginx";
    };
  };
  users.groups.searx.members = [ "searx" config.services.nginx.user ];
  services = {
    searx = {
      enable = true;
      package = pkgs.searxng;
      environmentFile = config.sops.secrets.searx-env.path;
      runInUwsgi = true;
      uwsgiConfig = {
        disable-logging = true;
        http = ":8088";                   # serve via HTTP...
        socket = "/run/searx/searx.sock"; # ...or UNIX socket
        chmod-socket = "660";
      };
      settings = {
        search = {
          autocomplete = "duckduckgo";
        };
        server = {
          port = 8088;
          image_proxy = true;
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

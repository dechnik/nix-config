{ pkgs, config, ... }:

let
  domain = "yt.pve.dechnik.net";
  port = 3000;
in {
  sops.secrets.invidious-config = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
    mode = "0444";
  };
  security.acme.certs."${domain}" = {
    domain = domain;
    group = "nginx";
  };
  services.nginx.virtualHosts = {
    "${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
      extraConfig = ''
        access_log /var/log/nginx/${domain}.access.log;
      '';
    };
  };

  services.invidious = {
    enable = true;
    # nginx.enable = true;
    inherit port domain;
    database.createLocally = true;
    settings = {
      use_quic = true;
      admins = ["lukasz"];
      channel_threads = 2;
      use_pubsub_feeds = true;
      https_only = false;
      popular_enabled = false;
      quality = "dash";
      quality_dash = "best";
    };
    extraSettingsFile = config.sops.secrets.invidious-config.path;
  };

  # Fix for random crashes dur to 'Invalid memory access'.
  # https://github.com/iv-org/invidious/issues/1439
  systemd.services.invidious.serviceConfig.Restart = "on-failure";
}

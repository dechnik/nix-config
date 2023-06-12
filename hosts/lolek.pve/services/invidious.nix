{ pkgs, config, ... }:

let
  domain = "yt.pve.dechnik.net";
  port = 3000;
in {
  services.invidious = {
    enable = true;
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
  };

  # Fix for random crashes dur to 'Invalid memory access'.
  # https://github.com/iv-org/invidious/issues/1439
  systemd.services.invidious.serviceConfig.Restart = "on-failure";
}

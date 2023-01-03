{ config, pkgs, ... }:
let
  hostName = "nextcloud.dechnik.net";
in
{
  services = {
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud25;
      enable = true;
      https = true;
      enableBrokenCiphersForSSE = false;
      home = "/media/nextcloud";
      config.adminuser = "root";
      config.adminpassFile = config.sops.secrets.nextcloud-password.path;
    };
  };

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };
}

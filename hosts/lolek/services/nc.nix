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
      caching.redis = true;
      config = {
        trustedProxies = ["10.30.10.12"];
        adminuser = "root";
        adminpassFile = config.sops.secrets.nextcloud-password.path;
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        defaultPhoneRegion = "PL";
      };
    };
    postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "DATABASE nextcloud" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "nextcloud" ];
    };
  };
  services.redis.servers.nextcloud.enable = true;
  services.redis.servers.nextcloud.unixSocketPerm = 770;

  users.users.nginx.extraGroups = [ "redis-nextcloud" ];
  users.users.nextcloud.extraGroups = [ "redis-nextcloud" ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };
}

{ pkgs, config, ... }:
let
  hostName = "nc.dechnik.net";
in
{
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };

  environment.persistence = {
    "/persist".directories = [ "/srv/nextcloud" ];
  };

  services = {
    redis.servers.nextcloud = {
      enable = true;
      user = "nextcloud";
      port = 0;
      bind = null;
    };
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud30;
      extraApps = with pkgs.nextcloud30Packages.apps; {
        inherit mail;
      };
      caching.redis = true;
      # Auto-update Nextcloud Apps
      # autoUpdateApps.enable = true;
      # Set what time makes sense for you
      # autoUpdateApps.startAt = "05:00:00";
      extraAppsEnable = true;
      enable = true;
      https = true;
      # enableBrokenCiphersForSSE = false;
      home = "/srv/nextcloud";
      maxUploadSize = "10G";
      phpOptions."opcache.interned_strings_buffer" = "23";
      config = {
        adminuser = "root";
        adminpassFile = config.sops.secrets.nextcloud-password.path;
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
      };
      settings = {
        redis = {
          host = "/run/redis-nextcloud/redis.sock";
          port = 0;
        };
        "memcache.local" = "\\OC\\Memcache\\Redis";
        "memcache.distributed" = "\\OC\\Memcache\\Redis";
        "memcache.locking" = "\\OC\\Memcache\\Redis";
        overwriteprotocol = "https";
        default_phone_region = "PL";
        "bulkupload.enabled" = false;
      };
    };
    postgresqlBackup = {
      enable = true;

      databases = [ "nextcloud" ];
    };
    postgresql = {
      ensureUsers = [
        {
          name = "nextcloud";
          # ensurePermissions = {
          #   "DATABASE nextcloud" = "ALL PRIVILEGES";
          # };
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "nextcloud" ];
    };
  };
}

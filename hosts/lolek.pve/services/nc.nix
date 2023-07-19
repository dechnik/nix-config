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
    "/persist".directories = [
      "/srv/nextcloud"
    ];
  };

  services = {
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud27;
      extraApps = with pkgs.nextcloud27Packages.apps; {
        inherit mail;
      };
      # Auto-update Nextcloud Apps
      # autoUpdateApps.enable = true;
      # Set what time makes sense for you
      # autoUpdateApps.startAt = "05:00:00";
      extraAppsEnable = true;
      enable = true;
      https = true;
      enableBrokenCiphersForSSE = false;
      home = "/srv/nextcloud";
      maxUploadSize = "10G";
      config = {
        adminuser = "root";
        adminpassFile = config.sops.secrets.nextcloud-password.path;
        overwriteProtocol = "https";
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        defaultPhoneRegion = "PL";
      };
      extraOptions = {
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
          ensurePermissions = {
            "DATABASE nextcloud" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "nextcloud" ];
    };
  };
}

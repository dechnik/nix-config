{ pkgs, config, ... }:
let
  hostName = "nextcloud.dechnik.net";
in
{
  security.acme.certs = {
    "nc.dechnik.net" = {
      group = "nginx";
    };
    "nextcloud.dechnik.net" = {
      group = "nginx";
    };
  };

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
      package = pkgs.nextcloud26;
      # extraApps = with pkgs.nextcloud25Packages.apps; {
      #   inherit oidc;
      # };
      # Auto-update Nextcloud Apps
      autoUpdateApps.enable = true;
      # Set what time makes sense for you
      autoUpdateApps.startAt = "05:00:00";
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
    nginx.virtualHosts."nextcloud.dechnik.net" = {
      forceSSL = true;
      useACMEHost = "nextcloud.dechnik.net";
      locations."/.well-known/openid-configuration" = {
        priority = 1;
        extraConfig = ''
          absolute_redirect off;
          return 301 /index.php/apps/oidc/openid-configuration;
        '';
        # return = "301 /index.php/apps/oidc/openid-configuration";
      };
      extraConfig = ''
        access_log /var/log/nginx/nextcloud.dechnik.net.access.log;
      '';
    };
    nginx.virtualHosts."nc.dechnik.net" = {
      forceSSL = true;
      # enableACME = true;
      useACMEHost = "nc.dechnik.net";
      locations = {
        "/" = {
          return = "302 https://nextcloud.dechnik.net$request_uri";
        };
      };
    };
  };
}

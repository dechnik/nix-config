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

  services = {
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud25;
      extraApps = with pkgs.nextcloud25Packages.apps; {
        inherit mail contacts;
      };
      extraAppsEnable = true;
      enable = true;
      https = true;
      enableBrokenCiphersForSSE = false;
      home = "/media/nextcloud";
      maxUploadSize = "10G";
      config = {
        trustedProxies = [ "10.30.10.12" ];
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

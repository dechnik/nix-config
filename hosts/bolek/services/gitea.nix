{ config, lib, pkgs, ... }:
{
  security.acme.certs = {
    "git.dechnik.net" = {
      group = "nginx";
    };
  };
  services = {
    nginx.virtualHosts = {
      "git.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "git.dechnik.net";
        extraConfig = ''
          access_log /var/log/nginx/git.dechnik.net.access.log;
        '';
        locations = {
          "/".proxyPass =
            "http://localhost:${toString config.services.gitea.httpPort}";
        };
      };
    };
    gitea = {
      enable = true;
      stateDir = "/srv/gitea";
      log = {
        level = "Warn";
      };
      user = "gitea";
      database = {
        type = "sqlite3";
        host = "127.0.0.1";
        name = "gitea";
        user = "gitea";
        path = "/srv/gitea/data/gitea.db";
        createDatabase = true;
      };
      ssh = {
        enable = true;
        clonePort = 22;
      };
      lfs = {
        enable = true;
        contentDir = "/srv/gitea/lfs";
      };
      appName = "SelfPrivacy git Service";
      repositoryRoot = "/srv/gitea/repositories";
      domain = "git.dechnik.net";
      rootUrl = "https://git.dechnik.net/";
      httpAddress = "0.0.0.0";
      httpPort = 3000;
      cookieSecure = true;
      settings = {
        mailer = {
          ENABLED = false;
        };
        ui = {
          DEFAULT_THEME = "gruvbox-dark";
        };
        picture = {
          DISABLE_GRAVATAR = true;
        };
        admin = {
          ENABLE_KANBAN_BOARD = true;
        };
        repository = {
          FORCE_PRIVATE = false;
        };
      };
    };
  };
  environment.persistence = {
    "/persist".directories = [ "/srv/gitea" ];
  };
}

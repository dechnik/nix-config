{ config, ... }:
let
  themeFile = ./theme-gruvbox-dark.css;
in
{
  services.traefik.dynamicConfigOptions.http = {
    services.gitea = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}"; }];
    };

    routers.gitea = {
      rule = "Host(`git.dechnik.net`)";
      service = "gitea";
      entryPoints = [ "web" ];
    };
  };
  system.activationScripts.gitea-theme = ''
    mkdir -p /srv/gitea/custom/public/css
    ln -sf ${themeFile} /srv/gitea/custom/public/css/theme-gruvbox-dark.css
  '';
  services = {
    gitea = {
      enable = true;
      stateDir = "/srv/gitea";
      user = "gitea";
      database = {
        type = "sqlite3";
        host = "127.0.0.1";
        name = "gitea";
        user = "gitea";
        path = "/srv/gitea/data/gitea.db";
        createDatabase = true;
      };
      dump = {
        enable = true;
        type = "tar.gz";
        backupDir = "/storage/gitea";
      };
      lfs = {
        enable = true;
        contentDir = "/srv/gitea/lfs";
      };
      appName = "SelfPrivacy git Service";
      repositoryRoot = "/srv/gitea/repositories";
      settings = {
        server = {
          SSH_PORT = 22;
          ROOT_URL = "https://git.dechnik.net/";
          HTTP_PORT = 3333;
          HTTP_ADDR = "0.0.0.0";
          DOMAIN = "git.dechnik.net";
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        log = {
          LEVEL = "Warn";
        };
        session = {
          COOKIE_SECURE = true;
        };
        mailer = {
          ENABLED = false;
        };
        ui = {
          THEMES = "auto,gitea,arc-green,gruvbox-dark";
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

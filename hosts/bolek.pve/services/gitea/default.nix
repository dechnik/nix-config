{ config, ... }:
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
        actions = {
          ENABLED = true;
        };
        session = {
          COOKIE_SECURE = true;
        };
        mailer = {
          ENABLED = false;
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

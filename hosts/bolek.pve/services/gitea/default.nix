{ config, ... }:
let
  themeFile = ./theme-gruvbox-dark.css;
in
{
  security.acme.certs = {
    "git.dechnik.net" = {
      group = "nginx";
    };
  };

  system.activationScripts.gitea-theme = ''
    mkdir -p /srv/gitea/custom/public/css
    ln -sf ${themeFile} /srv/gitea/custom/public/css/theme-gruvbox-dark.css
  '';
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
      httpPort = 3333;
      settings = {
        server = {
          SSH_PORT = 22;
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

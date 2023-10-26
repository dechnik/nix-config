{ config, inputs, ... }:
{
  imports = [
    inputs.gitness.nixosModules.default
  ];
  environment.persistence = {
    "/persist".directories = [
      "/var/lib/gitness"
    ];
  };
  sops.secrets = {
    gitness-env = {
      owner = "gitness";
      group = "gitness";
      sopsFile = ../secrets.yaml;
    };
  };
  users = {
    users = {
      gitness = {
        extraGroups = [
          "docker"
        ];
      };
    };
  };
  services = {
    gitness = {
      enable = true;
      httpPort = 3088;
      dataDir = "/var/lib/gitness";
      environmentFile = config.sops.secrets.gitness-env.path;
      environment = {
        GITNESS_DATABASE_DATASOURCE = "database.sqlite3";
        GITNESS_DATABASE_DRIVER = "sqlite3";
        GITNESS_DEBUG = "false";
        GITNESS_ENCRYPTER_MIXED_CONTENT = "false";
        GITNESS_GRACEFUL_SHUTDOWN_TIME = "300s";
        GITNESS_TOKEN_COOKIE_NAME = "token";
        GITNESS_TOKEN_EXPIRE = "720h";
        GITNESS_TRACE = "false";
        GITNESS_URL_API = "https://gitness.dechnik.net/api";
        GITNESS_URL_BASE = "https://gitness.dechnik.net";
        GITNESS_URL_GIT = "https://gitness.dechnik.net/git";
        GITNESS_URL_UI = "https://gitness.dechnik.net";
        GITNESS_URL_CONTAINER = "https://gitness.dechnik.net";
        GITNESS_USER_SIGNUP_ENABLED = "false";
      };
    };
  };
}

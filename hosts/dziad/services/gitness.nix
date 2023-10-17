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
  services.gitness = {
    enable = true;
    httpPort = 3000;
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
      GITNESS_URL_API = "http://localhost:3000/api";
      GITNESS_URL_BASE = "http://localhost:3000";
      GITNESS_URL_GIT = "http://localhost:3000/git";
      GITNESS_URL_UI = "http://localhost:3000";
      GITNESS_USER_SIGNUP_ENABLED = "false";
    };
  };
}

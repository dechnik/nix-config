{ config, lib, pkgs, ... }:
{
  sops.secrets = {
    gitlab-root-password = {
      owner = "git";
      group = "git";
      sopsFile = ../secrets.yaml;
    };
    gitlab-jws = {
      owner = "git";
      group = "git";
      sopsFile = ../secrets.yaml;
    };
    gitlab-db = {
      owner = "git";
      group = "git";
      sopsFile = ../secrets.yaml;
    };
    gitlab-otp = {
      owner = "git";
      group = "git";
      sopsFile = ../secrets.yaml;
    };
    gitlab-secret = {
      owner = "git";
      group = "git";
      sopsFile = ../secrets.yaml;
    };
  };
  users = {
    users = {
      git = {
        group = "git";
        isSystemUser = true;
        useDefaultShell = true;
      };
    };
  };
  services = {
    openssh.settings.AcceptEnv = "GIT_PROTOCOL";
    gitlab = {
      enable = true;
      statePath = "/var/lib/git/state";
      backup.path = "/var/lib/git/backup";
      databaseCreateLocally = true;
      databaseUsername = "git";
      databaseName = "git";
      user = "git";
      group = "git";
      host = "gitlab.dechnik.net";
      port = 443;
      https = true;
      initialRootEmail = "admin@dechnik.net";
      initialRootPasswordFile = config.sops.secrets.gitlab-root-password.path;
# Hack, https://github.com/NixOS/nixpkgs/pull/135926 broke stuff
      pages.settings.pages-domain = "not.actually.enabled";
      secrets = {
        dbFile = config.sops.secrets.gitlab-db.path;
        jwsFile = config.sops.secrets.gitlab-jws.path;
        otpFile = config.sops.secrets.gitlab-otp.path;
        secretFile = config.sops.secrets.gitlab-secret.path;
      };
      smtp = {
        enable = true;
        domain = "dechnik.net";
        address = "localhost";
        enableStartTLSAuto = false;
      };
    };
    traefik.dynamicConfigOptions.http = {
      services.gitlab = {
        loadBalancer.servers = [{ url = "http://unix:/run/gitlab/gitlab-workhorse.socket"; }];
      };

      routers.gitlab = {
        rule = "Host(`gitlab.dechnik.net`)";
        service = "gitlab";
        entryPoints = [ "web" ];
      };
    };
  };
}

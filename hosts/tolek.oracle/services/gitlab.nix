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
    gitlab-ldap-password = {
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
        port = 25;
        enableStartTLSAuto = false;
      };
      extraConfig = {
        ldap = {
          enabled = true;
          servers = {
            main = {
              label = "LDAP";
              host = "127.0.0.1";
              port = 3890;
              timeout = 10;
              uid = "uid";
              active_directory = false;
              verify_certificates = false;
              bind_dn = "uid=ro_admin,ou=people,dc=dechnik,dc=net";
              password = {_secret = config.sops.secrets.gitlab-ldap-password.path;};
              base = "ou=people,dc=dechnik,dc=net";
              encryption = "plain";
              user_filter = "(&(objectclass=person)(memberOf=cn=gitlab,ou=groups,dc=dechnik,dc=net))";
              allow_username_or_email_login = false;
              block_auto_created_users = false;
              lowercase_usernames = false;
              attributes = {
                username = "uid";
                email = "mail";
                name = "displayName";
                first_name = "givenName";
                last_name = "sn";
              };
            };
          };
        };
      };
    };
    traefik.dynamicConfigOptions.http = {
      services.gitlab = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:8080"; }];
      };

      routers.gitlab = {
        rule = "Host(`gitlab.dechnik.net`)";
        service = "gitlab";
        entryPoints = [ "web" ];
      };
    };
    nginx = {
      enable = true;
      defaultHTTPListenPort = 8080;
      virtualHosts = {
        "gitlab.dechnik.net" = {
          locations."/" = {
            proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            extraConfig = ''
              client_max_body_size 50M;
            '';
          };
        };
      };
    };
  };
}

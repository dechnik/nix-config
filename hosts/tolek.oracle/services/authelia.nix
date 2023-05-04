{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia.instances.main;
in
{
  sops.secrets = {
    authelia-ldap-backend-pass = {
      owner = cfg.user;
      group = cfg.group;
      sopsFile = ../secrets.yaml;
    };
    authelia-jwt-secret = {
      owner = cfg.user;
      group = cfg.group;
      sopsFile = ../secrets.yaml;
    };
    authelia-oidc-issuer-private-key = {
      owner = cfg.user;
      group = cfg.group;
      sopsFile = ../secrets.yaml;
    };
    authelia-oidc-hmac-secret = {
      owner = cfg.user;
      group = cfg.group;
      sopsFile = ../secrets.yaml;
    };
    authelia-storage-encryption-key = {
      owner = cfg.user;
      group = cfg.group;
      sopsFile = ../secrets.yaml;
    };
  };
  environment.persistence = {
    "/persist".directories = [
      "/var/lib/authelia"
    ];
  };

  services.authelia.instances.main = {
    enable = true;
    settings = {
      theme = "dark";
      log = {
        level = "info";
        format = "text";
      };
      server = {
        host = "127.0.0.1";
        port = 9091;
      };
      session = {
        name = "session";
        domain = "dechnik.net";
      };
      authentication_backend.ldap = {
        implementation = "custom";
        url = "ldap://127.0.0.1:3890";
        base_dn = "dc=dechnik,dc=net";
        username_attribute = "uid";
        additional_users_dn = "ou=people";
        users_filter = "(&({username_attribute}={input})(objectclass=person))";
        additional_groups_dn = "ou=groups";
        groups_filter = "(member={dn})";
        group_name_attribute = "cn";
        mail_attribute = "mail";
        display_name_attribute = "uid";
        user = "uid=authelia,ou=people,dc=dechnik,dc=net";
      };
      storage.local = {
        path = "/var/lib/authelia/authelia-${cfg.name}/db.sqlite3";
      };
      access_control = {
        default_policy = "deny";
      };
      notifier.smtp = rec {
        host = "localhost";
        port = 25;
        sender = "monitoring@dechnik.net";
        disable_html_emails = true;
      };
      identity_providers.oidc = {
        cors.allowed_origins_from_client_redirect_uris = true;
        cors.endpoints = [
          "authorization"
          "introspection"
          "revocation"
          "token"
          "userinfo"
        ];
      };
    };
    secrets = with config.sops.secrets; {
      jwtSecretFile = authelia-jwt-secret.path;
      oidcIssuerPrivateKeyFile = authelia-oidc-issuer-private-key.path;
      oidcHmacSecretFile = authelia-oidc-hmac-secret.path;
      storageEncryptionKeyFile = authelia-storage-encryption-key.path;
    };

    environmentVariables = with config.sops.secrets; {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = authelia-ldap-backend-pass.path;
    };
  };
}

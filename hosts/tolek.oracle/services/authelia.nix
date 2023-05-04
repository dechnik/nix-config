{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia.instances.main;
in
{
  security.acme.certs = {
    "auth.dechnik.net" = {
      group = "nginx";
    };
  };

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
      # TODO access control: 'default_policy' option 'deny' is invalid: when no rules are specified it must be 'two_factor' or 'one_factor'
      access_control = {
        default_policy = "deny";
      };
      notifier.smtp = rec {
        host = "localhost";
        port = 25;
        sender = "monitoring@dechnik.net";
        disable_html_emails = true;
      };
      # TODO identity_providers: oidc: option 'clients' must have one or more clients configured"
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
  services.nginx.virtualHosts = {
    "auth.dechnik.net" = {
      forceSSL = true;
      useACMEHost = "auth.dechnik.net";
      locations."/".proxyPass = "http://localhost:${toString cfg.settings.server.port}/";
      extraConfig = ''
        client_body_buffer_size 128k;

        # Advanced Proxy Config
        send_timeout 5m;
        proxy_read_timeout 360;
        proxy_send_timeout 360;
        proxy_connect_timeout 360;

        # Basic Proxy Config
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Uri $request_uri;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_redirect  http://  $scheme://;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_cache_bypass $cookie_session;
        proxy_no_cache $cookie_session;
        proxy_buffers 64 256k;
      '';
    };
  };
}

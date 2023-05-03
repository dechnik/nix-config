{ lib, config, ... }:
let
  nginx = import ../../../common/functions/nginx.nix { inherit config lib; };
in
  lib.mkMerge [
  {
    environment.persistence = {
      "/persist".directories = [
        "/var/lib/lldap"
      ];
    };

    sops.secrets = {
      lldap-jwt-secret = {
        owner = "lldap";
        group = "lldap";
        sopsFile = ../secrets.yaml;
      };
      lldap-admin-pass = {
        owner = "lldap";
        group = "lldap";
        sopsFile = ../secrets.yaml;
      };
    };
    services.lldap = {
      enable = true;
      environment = {
        LLDAP_JWT_SECRET_FILE = config.sops.secrets.lldap-jwt-secret.path;
        LLDAP_LDAP_USER_PASS_FILE = config.sops.secrets.lldap-admin-pass.path;
      };
      settings = {
        ldap_user_email = "admin@dechnik.net";
        ldap_user_dn = "admin";
        ldap_port = 3890;
        ldap_host = "127.0.0.1";
        ldap_base_dn = "dc=dechnik,dc=net";
        http_url = "https://ldap.dechnik.net";
        http_port = 17170;
        http_host = "127.0.0.1";
      };
    };
  }

  (nginx.internalVhost {
    domain = "ldap.dechnik.net";
    tailscaleAuth = false;
    proxyPass = "http://127.0.0.1:${toString config.services.lldap.settings.http_port}";
  })
]

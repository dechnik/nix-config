{ lib, inputs, config, ... }:
let
  nginx = import ../../../common/functions/nginx.nix { inherit config lib; };
in
  {
    imports = [
      inputs.lldap.nixosModules.default
    ];
    disabledModules = [ "services/databases/lldap.nix" ];
  }
  // lib.mkMerge [
  {
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
      jwtSecretFile = config.sops.secrets.lldap-jwt-secret.path;
      userPassFile = config.sops.secrets.lldap-admin-pass.path;
      dataDir = "/srv/lldap";
      ldapHost = "0.0.0.0";
      ldapPort = 3890;
      httpHost = "127.0.0.1";
      httpPort = 17170;
      openFirewall = true;
      httpUrl = "https://ldap.dechnik.net";
      ldapBaseDn = "dc=dechnik,dc=net";
      ldapUserDn = "admin";
      ldapUserEmail = "admin@dechnik.net";
    };
  }

  (nginx.internalVhost {
    domain = "ldap.dechnik.net";
    tailscaleAuth = false;
    proxyPass = "http://127.0.0.1:${toString config.services.lldap.httpPort}";
  })
]

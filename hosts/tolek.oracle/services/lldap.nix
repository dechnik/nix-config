{ inputs, config, ... }:
{
  imports = [
    inputs.lldap.nixosModules.default
  ];
  disabledModules = [ "services/databases/lldap.nix" ];

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

  services.traefik.dynamicConfigOptions.http = {
    services.lldap = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:17170"; }];
    };

    routers.lldap = {
      rule = "Host(`ldap.dechnik.net`)";
      service = "lldap";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };
}

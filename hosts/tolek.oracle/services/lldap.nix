{ inputs, config, ... }:
{
  # disabledModules = [ "services/databases/lldap.nix" ];

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
    openFirewall = true;
    settings = {
      ldap_host = "0.0.0.0";
      ldap_port = 3890;
      http_host = "10.61.0.1";
      http_port = 17170;
      http_url = "https://ldap.dechnik.net";
      ldap_base_dn = "dc=dechnik,dc=net";
      ldap_user_dn = "admin";
      ldap_user_email = "admin@dechnik.net";
      database_url = "sqlite:///srv/lldap/users.db?mode=rwc";
      key_file = "/srv/lldap/private-key";
    };
  };

  # services.lldap = {
  #   enable = true;
  #   jwtSecretFile = config.sops.secrets.lldap-jwt-secret.path;
  #   userPassFile = config.sops.secrets.lldap-admin-pass.path;
  #   dataDir = "/srv/lldap";
  #   ldapHost = "0.0.0.0";
  #   ldapPort = 3890;
  #   httpHost = "127.0.0.1";
  #   httpPort = 17170;
  #   openFirewall = true;
  #   httpUrl = "https://ldap.dechnik.net";
  #   ldapBaseDn = "dc=dechnik,dc=net";
  #   ldapUserDn = "admin";
  #   ldapUserEmail = "admin@dechnik.net";
  # };

  services.traefik.dynamicConfigOptions.http = {
    services.lldap = {
      loadBalancer.servers = [{ url = "http://10.61.0.1:17170"; }];
    };

    routers.lldap = {
      rule = "Host(`ldap.dechnik.net`)";
      service = "lldap";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };
}

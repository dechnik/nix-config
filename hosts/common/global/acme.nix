{ lib, config, ... }:
{
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults = {
      email = "lukasz@dechnik.net";
      dnsProvider = "route53";
      credentialsFile = config.sops.secrets.acme-credentials.path;
    };
    acceptTerms = true;
  };

  sops.secrets.acme-credentials = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/acme"
      ];
    };
  };
}

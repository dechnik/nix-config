{ lib, config, ... }:
{
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults = {
      email = "lukasz@dechnik.net";
      # dnsProvider = "route53";
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets.acme-credentials.path;
      group = "nginx";
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

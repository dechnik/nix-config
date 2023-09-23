{ lib, config, ... }:
{
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults = {
      email = "lukasz@dechnik.net";
      # dnsProvider = "route53";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.acme-credentials.path;
      group = "acme";
    };
    acceptTerms = true;
  };
  users.groups.acme = { };

  sops.secrets.acme-credentials = {
    sopsFile = ../secrets.yaml;
    group = config.security.acme.defaults.group;
  };

  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/acme"
      ];
    };
  };
}

{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-mailserver.nixosModules.mailserver
  ];
  mailserver = rec {
    enable = true;
    fqdn = "mail.dechnik.net";
    sendingFqdn = "mail.dechnik.net";
    domains = [
      "dechnik.net"
      "pve.dechnik.net"
    ];
    useFsLayout = true;
    certificateScheme = 3;
    localDnsResolver = false;
    loginAccounts = {
      "lukasz@dechnik.net" = {
        hashedPasswordFile = config.sops.secrets.lukasz-mail-password.path;
        aliases = [
          "admin@dechnik.net"
          "dechnik@dechnik.net"
          "postmaster@dechnik.net"
        ];
      };
      "monitoring@dechnik.net" = {
        hashedPasswordFile = config.sops.secrets.monitoring-mail-password.path;
        aliases = [
          "grafana@dechnik.net"
          "alertmanager@dechnik.net"
          "monitoring@pve.dechnik.net"
          "grafana@pve.dechnik.net"
          "alertmanager@pve.dechnik.net"
        ];
      };
    };
    mailboxes = {
      Archive = {
        auto = "subscribe";
        specialUse = "Archive";
      };
      Drafts = {
        auto = "subscribe";
        specialUse = "Drafts";
      };
      Sent = {
        auto = "subscribe";
        specialUse = "Sent";
      };
      Junk = {
        auto = "subscribe";
        specialUse = "Junk";
      };
      Trash = {
        auto = "subscribe";
        specialUse = "Trash";
      };
    };
    # When setting up check that /srv is persisted!
    mailDirectory = "/srv/mail/vmail";
    sieveDirectory = "/srv/mail/sieve";
    dkimKeyDirectory = "/srv/mail/dkim";
  };

  # Prefer ipv4 and use main ipv6 to avoid reverse DNS issues
  # CHANGEME when switching hosts
  services.postfix.extraConfig = ''
    smtp_address_preference = ipv4
  '';

  sops.secrets = {
    lukasz-mail-password = {
      sopsFile = ../secrets.yaml;
    };
    monitoring-mail-password = {
      sopsFile = ../secrets.yaml;
    };
  };

  # Webmail
  # services.roundcube = rec {
  #   enable = true;
  #   package = pkgs.roundcube.withPlugins (p: [ p.carddav ]);
  #   hostName = "mail.dechnik.net";
  #   extraConfig = ''
  #     $config['smtp_server'] = "tls://${hostName}";
  #     $config['smtp_user'] = "%u";
  #     $config['smtp_pass'] = "%p";
  #     $config['plugins'] = [ "carddav" ];
  #   '';
  # };
}

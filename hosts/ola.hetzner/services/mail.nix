{ lib, config, pkgs, inputs, ... }:
let
  consul = import ../../../common/functions/consul.nix { inherit lib; };
in
{
  imports = [
    inputs.nixos-mailserver.nixosModules.mailserver
  ];
  # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/275
  services.dovecot2.sieve.extensions = [ "fileinto" ];
  mailserver = rec {
    enable = true;
    fqdn = "mail.dechnik.net";
    sendingFqdn = "mail.dechnik.net";
    domains = [
      "dechnik.net"
      "pve.dechnik.net"
    ];
    useFsLayout = true;
    localDnsResolver = false;
    extraVirtualAliases = {
      "abuse@dechnik.net" = "lukasz@dechnik.net";
    };
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
    certificateScheme = "manual";
    certificateFile = "/var/lib/acme/mail.dechnik.net/fullchain.pem";
    keyFile = "/var/lib/acme/mail.dechnik.net/key.pem";
  };

  security.acme.certs = {
    "mail.dechnik.net" = {
      domain = "mail.dechnik.net";
    };
  };

  users.users.dovecot2.extraGroups = [ "acme" ];
  users.users.postfix.extraGroups = [ "acme" ];

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

  services.prometheus.exporters.postfix = {
    enable = true;
    openFirewall = true;
  };

  my.consulServices.postfix_exporter = consul.prometheusExporter "postfix" config.services.prometheus.exporters.postfix.port;

  services.prometheus.exporters.dovecot = {
    enable = true;
    openFirewall = true;
  };

  my.consulServices.dovecot_exporter = consul.prometheusExporter "dovecot" config.services.prometheus.exporters.dovecot.port;

  services.prometheus.exporters.rspamd = {
    enable = true;
    openFirewall = true;
  };

  my.consulServices.rspamd_exporter = consul.prometheusExporter "rspamd" config.services.prometheus.exporters.rspamd.port;

  services.nginx = {
    enable = true;
    defaultHTTPListenPort = 8080;
    virtualHosts = {
      "roundcube.dechnik.net" = {
        forceSSL = lib.mkForce false;
        enableACME = lib.mkForce false;
      };
    };
  };
  # Webmail
  services.roundcube = rec {
    enable = true;
    package = pkgs.roundcube.withPlugins (p: [ p.carddav ]);
    hostName = "roundcube.dechnik.net";
    extraConfig = ''
      $config['smtp_server'] = "tls://mail.dechnik.net";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['plugins'] = [ "carddav" ];
    '';
  };
}

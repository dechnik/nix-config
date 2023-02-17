{
  lib,
  config,
  pkgs,
  ...
}: let
  folder-config = import ./folder-config.nix {inherit config lib;};
  maildirBase = "${config.xdg.dataHome}/mail";
  protonmail-cli = pkgs.writeShellScriptBin "protonmail-cli" ''
    systemctl --user stop protonmail-bridge.service
    ${pkgs.protonmail-bridge}/bin/protonmail-bridge --cli
    systemctl --user start protonmail-bridge.service
  '';
in {
  home.persistence = {
    "/persist/mail/lukasz" = {
      directories = [
        ".config/protonmail"
      ];
      allowOther = true;
    };
  };
  home.packages = [
    protonmail-cli
  ];

  systemd.user.services.protonmail-bridge = {
    Install.WantedBy = [ "default.target" ];

    Unit = {
      Description = "Protonmail Bridge";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge -l info --noninteractive";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  accounts.email.accounts = {
    "proton" = {
      address = "lukasz@dechnik.net";
      aliases = [
        "ldechnik@pm.me"
        "admin@dechnik.net"
        "dechnik@dechnik.net"
      ];
      realName = "Lukasz Dechnik";
      primary = true;
      userName = "ldechnik@protonmail.com";
      passwordCommand = "${config.programs.password-store.package}/bin/pass ldechnik@pm.me";
      imap = {
        host = "127.0.0.1";
        port = 1143;
        tls = {
          enable = true;
          useStartTls = true;
          certificatesFile = "${config.home.homeDirectory}/.config/protonmail/bridge/cert.pem";
        };
      };
      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls = {
          enable = true;
          useStartTls = true;
          certificatesFile = "${config.home.homeDirectory}/.config/protonmail/bridge/cert.pem";
        };
      };
      gpg = {
        key = "D627C2E908C218A4";
        signByDefault = true;
      };
      mbsync = {
        create = "both";
        remove = "maildir";
        expunge = "both";
        patterns = [
          "INBOX"
          "Sent"
          "Archive"
          "Drafts"
          "Trash"
        ];
        enable = true;
      };
      msmtp = {
        enable = true;
        extraConfig.from = "lukasz@dechnik.net";
        # extraConfig.domain = osConfig.networking.hostName;
      };
      neomutt = {
        enable = true;
        sendMailCommand = "msmtpq --read-recipients";
        extraConfig = folder-config config.accounts.email.accounts;
      };
      display-folders = [
        "Inbox"
        "Sent"
        "Drafts"
      ];
      signature = {
        showSignature = "append";
        command = "${maildirBase}/.sig/lukasz";
      };
      sig-org = ''


Regards,
#+begin_signature
--
*Lukasz Dechnik*
PGP mail accepted and encouraged.
Key Id: D7BCC570927C355B
https://keys.openpgp.org/vks/v1/by-fingerprint/35655963B7835180125FE55DD7BCC570927C355B
#+end_signature
      '';
      mu.enable = true;
      # imapnotify = {
      #   enable = true;
      #   boxes = ["INBOX"];
      #   onNotify = "systemctl --user start mbsync.service";
      # };
    };
  };

  services.mbsync.enable = true;
}

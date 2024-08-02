{
  lib,
  config,
  pkgs,
  ...
}:
let
  folder-config = import ./folder-config.nix { inherit config lib; };
  maildirBase = "${config.xdg.dataHome}/mail";

  inherit (config) mailhost;
in
{
  home.persistence = {
    "/persist/home/lukasz".directories = [ ".config/oauth2ms" ];
  };

  home.activation = {
    oauth2ms-config = ''
      mkdir -p "$HOME/.config/oauth2ms"
      ln -sf "/run/oauth2ms" "$HOME/.config/oauth2ms/config.json"
    '';
  };
  systemd.user.services.mbsync.Service.Environment = [
    "SASL_PATH=${
      lib.concatStringsSep ":" [
        "${pkgs.cyrus_sasl.out}/lib/sasl2"
        "${pkgs.cyrus-sasl-xoauth2}/usr/lib/sasl2"
      ]
    }"
  ];
  accounts.email.accounts = {
    "ebi" = {
      address = "lukasz@ebimedia.pl";
      realName = "Lukasz Dechnik";
      userName = "lukasz@ebimedia.pl";
      passwordCommand = "${pkgs.oauth2ms}/bin/oauth2ms";
      thunderbird = {
        enable = true;
        profiles = [ "lukasz" ];
      };
      imap = {
        host = "outlook.office365.com";
        port = 993;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };
      smtp = {
        host = "smtp.office365.com";
        port = 587;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };
      gpg = {
        key = "4FF55C0369CABA69";
        signByDefault = true;
      };
      mbsync = {
        create = "both";
        remove = "maildir";
        expunge = "both";
        patterns = [
          "INBOX"
          "Sent Items"
          "Archive"
        ];
        enable = true;
        extraConfig.account = {
          AuthMechs = "XOAUTH2";
          # SSLVersions = "TLSv1.2";
        };
      };
      msmtp = {
        enable = true;
        extraConfig.from = "lukasz@ebimedia.pl";
        extraConfig.domain = mailhost;
        extraConfig.auth = "xoauth2";
      };
      neomutt = {
        enable = true;
        sendMailCommand = "msmtpq --read-recipients";
        extraConfig = folder-config config.accounts.email.accounts;
      };
      display-folders = [
        "Inbox"
        "Sent Items"
        "Sent"
        "Archive"
      ];
      signature = {
        showSignature = "append";
        command = "${maildirBase}/.sig/ebi";
      };
      sig-org = ''


        #+begin_signature
        --
        #+INCLUDE: ~/.local/share/mail/.sig/ebi.sig export html
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

{ lib
, config
, pkgs
, ...
}:
let
  folder-config = import ./folder-config.nix { inherit config lib; };
  maildirBase = "${config.xdg.dataHome}/mail";
  inherit (config) mailhost;
in
{
  accounts.email.accounts = {
    "dechnik" = {
      address = "lukasz@dechnik.net";
      aliases = [
        "admin@dechnik.net"
        "dechnik@dechnik.net"
      ];
      thunderbird = {
        enable = true;
        profiles = [ "lukasz" ];
      };
      realName = "Lukasz Dechnik";
      primary = true;
      userName = "lukasz@dechnik.net";
      passwordCommand = "${config.programs.password-store.package}/bin/pass mail.dechnik.net/lukasz@dechnik.net";
      imap = {
        host = "mail.dechnik.net";
        port = 993;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };
      smtp = {
        host = "mail.dechnik.net";
        port = 587;
        tls = {
          enable = true;
          useStartTls = true;
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
        extraConfig.domain = mailhost;
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

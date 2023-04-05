{ pkgs
, lib
, config
, ...
}:
let
  contexts-config = import ./contexts.nix { inherit config lib; };
  maildirBase = "${config.xdg.dataHome}/mail";
in
{
  config.home.persistence = {
    "/persist/mail/lukasz" = {
      directories = [
        ".local/share/mail"
      ];
      allowOther = true;
    };
  };

  config.home.file = {
    "${maildirBase}/.sig" = {
      source = ./sig;
      recursive = true;
    };
    "${maildirBase}/.templates" = {
      source = ./templates;
      recursive = true;
    };
    "${maildirBase}/.emacs/contexts.el" = {
      text = contexts-config config.accounts.email.accounts;
    };
    "${maildirBase}/.emacs/send.el" = {
      text = ''
        (setq sendmail-program "${pkgs.msmtp}/bin/msmtp"
              send-mail-function #'smtpmail-send-it
              message-sendmail-f-is-evil t
              message-sendmail-extra-arguments '("--read-envelope-from"); , "--read-recipients")
              message-send-mail-function #'message-send-mail-with-sendmail)
      '';
    };
  };

  options.accounts.email.accounts = with lib;
    mkOption { type = with types; attrsOf (submodule (import ./options.nix)); };

  config.programs = {
    pandoc.enable = true;
    mbsync.enable = true;
    msmtp.enable = true;
    mu.enable = true;
  };

  config.accounts.email.maildirBasePath = maildirBase;

  config.systemd.user.services.mbsync = {
    Service =
      let keyring = import ../keyring.nix { inherit pkgs; };
      in
      {
        ExecCondition = ''
          /bin/sh -c "${keyring.isUnlocked}"
        '';
      };
  };

  config.services.mbsync = {
    preExec = "${config.xdg.dataHome}/mail/.presync";
    postExec = "${config.xdg.dataHome}/mail/.postsync";
    frequency = "*:0/5";
  };

  config.services.imapnotify.enable = true;

  config.xdg.dataFile."mail/.postsync" = {
    executable = true;
    text = with lib; let
      mbsyncAccounts =
        filter (a: a.mbsync.enable)
          (attrValues config.accounts.email.accounts);
    in
    ''
      #!/bin/sh
      lastrun="${config.xdg.dataHome}/mail/.mailsynclastrun"
      for acc in ${concatMapStringsSep " " (a: a.name) mbsyncAccounts}; do
        new=$(${pkgs.findutils}/bin/find ${config.xdg.dataHome}/mail/$acc/[Ii][Nn][Bb][Oo][Xx]/new/ ${config.xdg.dataHome}/mail/$acc/[Ii][Nn][Bb][Oo][Xx]/cur/ -type f -newer "$lastrun" 2> /dev/null)
        newcount=$(echo "$new" | ${pkgs.gnused}/bin/sed '/^\s*$/d' | ${pkgs.coreutils}/bin/wc -l)
        case 1 in
          $((newcount > 0)) ) ${pkgs.libnotify}/bin/notify-send --app-name="mail" "New mail!" "📬  $newcount new mail(s) in \`$acc\` account."
        esac
      done
      ${pkgs.coreutils}/bin/touch "$lastrun"
      /etc/profiles/per-user/lukasz/bin/emacsclient -e '(mu4e-update-index)'
    '';
  };

  config.xdg.dataFile."mail/.presync" = {
    executable = true;
    text = with lib; let
      mbsyncAccounts =
        filter (a: a.mbsync.enable)
          (attrValues config.accounts.email.accounts);
    in
    ''
      #!/bin/sh
      for account in ${concatMapStringsSep " " (a: a.name) mbsyncAccounts}; do
        target="${config.xdg.dataHome}/mail/$account/.null"
        ${pkgs.coreutils}/bin/ln -sf /dev/null "$target"
      done
    '';
  };

  # We use msmtpq to send email, which means if we save the mail offline we
  # can run this queue runner from time to time.
  config.systemd.user.services.msmtp-queue-runner = {
    Unit = { Description = "msmtp-queue runner"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.msmtp}/bin/msmtp-queue -r";
    };
  };

  config.systemd.user.timers.msmtp-queue-runner = {
    Unit = { Description = "msmtp-queue runner"; };
    Timer = {
      Unit = "msmtp-queue-runner.service";
      OnCalendar = "*:0/5";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}

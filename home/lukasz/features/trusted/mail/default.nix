{ pkgs
, lib
, config
, ...
}:
let
  convert-multipart = import ./convert-multipart.nix pkgs;
  contexts-config = import ./contexts.nix { inherit config lib; };
  maildirBase = "${config.xdg.dataHome}/mail";
  muttConfig = ''
    set edit_headers = yes
    set fast_reply = yes
    set postpone = ask-no
    set read_inc = '100'
    set reverse_alias = yes
    set rfc2047_parameters = yes
    set charset = 'utf-8'
    set markers = no
    set menu_scroll = yes
    set write_inc = '100'
    set pgp_verify_command = '${pkgs.gnupg}/bin/gpg --status-fd=2 --verbose --batch --output - --verify-options show-uid-validity --verify %s %f'
    set query_command = "${pkgs.abook}/bin/abook --config $XDG_CONFIG_HOME/abook/abookrc --datafile $HOME/Documents/abook/addressbook --mutt-query '%s'"
    set mailcap_path = "~/.config/neomutt/mailcap"
    set beep_new = yes
    set collapse_unread = no
    set delete = yes
    set move = no
    set mime_forward = ask-yes
    set use_envelope_from = yes
    set quit = ask-no
    set sort = reverse-date
    set suspend = no
    set mark_old = no
    set wait_key = no
    set strict_threads = yes
    auto_view text/html
  '';
  muttColours = ''
    # Default index colors:
    color index yellow default '.*'
    color index_author red default '.*'
    color index_number blue default
    color index_subject cyan default '.*'

    # New mail is boldened:
    color index brightyellow black "~N"
    color index_author brightred black "~N"
    color index_subject brightcyan black "~N"

    # Tagged mail is highlighted:
    color index brightyellow blue "~T"
    color index_author brightred blue "~T"
    color index_subject brightcyan blue "~T"

    # Other colors and aesthetic settings:
    mono bold bold
    mono underline underline
    mono indicator reverse
    mono error bold
    color normal default default
    color indicator brightblack white
    color sidebar_highlight red default
    color sidebar_divider brightblack black
    color sidebar_flagged red black
    color sidebar_new green black
    color normal brightyellow default
    color error red default
    color tilde black default
    color message cyan default
    color markers red white
    color attachment yellow default
    color search brightmagenta default
    color status brightyellow black
    color hdrdefault brightgreen default
    color quoted green default
    color quoted1 blue default
    color quoted2 cyan default
    color quoted3 yellow default
    color quoted4 red default
    color quoted5 brightred default
    color signature brightgreen default
    color bold black default
    color underline black default
    color normal default default

    # Regex highlighting:
    color header brightmagenta default "^From"
    color header brightcyan default "^Subject"
    color header brightwhite default "^(CC|BCC)"
    color header blue default ".*"
    color body brightred default "[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+" # Email addresses
    color body brightblue default "(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+" # URL
    color body green default "\`[^\`]*\`" # Green text between ` and `
    color body brightblue default "^# \.*" # Headings as bold blue
    color body brightcyan default "^## \.*" # Subheadings as bold cyan
    color body brightgreen default "^### \.*" # Subsubheadings as bold green
    color body yellow default "^(\t| )*(-|\\*) \.*" # List items as yellow
    color body brightcyan default "[;:][-o][)/(|]" # emoticons
    color body brightcyan default "[;:][)(|]" # emoticons
    color body brightcyan default "[ ][*][^*]*[*][ ]?" # more emoticon?
    color body brightcyan default "[ ]?[*][^*]*[*][ ]" # more emoticon?
    color body red default "(BAD signature)"
    color body cyan default "(Good signature)"
    color body brightblack default "^gpg: Good signature .*"
    color body brightyellow default "^gpg: "
    color body brightyellow red "^gpg: BAD signature from.*"
    mono body bold "^gpg: Good signature"
    mono body bold "^gpg: BAD signature from.*"
    color body red default "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)? \t\r\n<>\"]"
  '';
  muttHeaders = ''
    ignore *
    unignore from to cc subject date list-id
  '';
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

  config.xdg = {
    desktopEntries = {
      neomutt = {
        name = "Neomutt";
        genericName = "Email Client";
        comment = "Read and send emails";
        exec = "neomutt %U";
        icon = "mutt";
        terminal = true;
        categories = [ "Network" "Email" "ConsoleOnly" ];
        type = "Application";
        mimeType = [ "x-scheme-handler/mailto" ];
      };
    };
    mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = "neomutt.desktop";
    };
    configFile = {
      "neomutt/mailcap" = {
        text = ''
        text/html; lynx -assume_charset=%{charset} -display_charset=utf-8 -dump -width=1024 %s; nametemplate=%s.html; copiousoutput;
        image/*; imv %s &
        audio/*; mpv %s ;
        video/*; setsid mpv --quiet %s &; copiousoutput
        application/pdf; zathura %s &
      '';
      };
    };
  };

  config.home.packages = with pkgs; [
    neomutt
    abook
    lynx
  ];

  options.accounts.email.accounts = with lib;
    mkOption { type = with types; attrsOf (submodule (import ./options.nix)); };

  config.programs = {
    pandoc.enable = true;
    mbsync.enable = true;
    msmtp.enable = true;
    mu.enable = true;
    neomutt = {
      enable = true;
      sidebar = {
        enable = true;
        shortPath = true;
        format = "%D%?F? [%F]?%* %?N?%N/?%?S?%S?";
        width = 22;
      };
      checkStatsInterval = 60;
      editor = "nvim +/^$ ++1";
      extraConfig = ''
        # General config
        ${muttConfig}
        # Colours
        ${muttColours}
        # Headers
        ${muttHeaders}
      '';
      binds = [
        {
          map = ["index" "pager"];
          key = "g";
          action = "noop";
        }
        {
          map = ["index"];
          key = "j";
          action = "next-entry";
        }
        {
          map = ["index"];
          key = "k";
          action = "previous-entry";
        }
        {
          map = ["pager"];
          key = "j";
          action = "next-line";
        }
        {
          map = ["pager"];
          key = "k";
          action = "previous-line";
        }
        {
          map = ["index"];
          key = "<esc>,";
          action = "sidebar-prev";
        }
        {
          map = ["index"];
          key = "<esc>.";
          action = "sidebar-next";
        }
        {
          map = ["index"];
          key = "<esc><enter>";
          action = "sidebar-open";
        }
        {
          map = ["index"];
          key = "<esc><return>";
          action = "sidebar-open";
        }
        {
          map = ["index"];
          key = "<esc><space>";
          action = "sidebar-open";
        }
        {
          map = ["editor"];
          key = "<Tab>";
          action = "complete-query";
        }
      ];
      macros = [
        {
          map = ["index"];
          key = "<esc>n";
          action = "<limit>~N<enter>";
        }
        {
          map = ["index"];
          key = "<esc>V";
          action = "<change-folder-readonly>${maildirBase}/mu<enter>";
        }
        {
          map = ["index"];
          key = "V";
          action = "<change-folder-readonly>${maildirBase}/mu<enter><shell-escape>mu find --format=links --linksdir=${maildirBase}/mu --clearlinks ";
        }
        {
          map = ["compose"];
          key = "Y";
          action = "<first-entry><pipe-entry>${convert-multipart}<enter><enter-command>source /tmp/neomutt-commands<enter>";
        }
        {
          map = ["index" "pager"];
          key = "a";
          action = "<enter-command>set my_pipe_decode=\$pipe_decode pipe_decode<return><pipe-message>${pkgs.abook}/bin/abook --config $XDG_CONFIG_HOME/abook/abookrc --datafile $HOME/Documents/abook/addressbook --add-email<return><enter-command>set pipe_decode=\$my_pipe_decode; unset my_pipe_decode<return>";
        }
        {
          map = ["index" "pager"];
          key = "gi";
          action = "<change-folder>=Inbox<enter>";
        }
        {
          map = ["index" "pager"];
          key = "gs";
          action = "<change-folder>=Sent<enter>";
        }
      ];
    };
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
      # ${pkgs.mu}/bin/mu index
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

{ config
, pkgs
, lib
, ...
}: {
  # home.packages = [pkgs.pure-prompt];
  home.persistence = {
    "/persist/home/lukasz" = {
      directories = [
        ".local/share/zsh"
      ];
      allowOther = true;
    };
  };

  programs.zsh = {
    enable = true;
    dirHashes = {
      dl = "$HOME/Downloads";
      docs = "$HOME/Documents";
      pics = "$HOME/Pictures";
      vids = "$HOME/Videos";
    };
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      save = 150000;
      size = 150000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = ''
      # autoloads
      autoload -U history-search-end
      # search history based on what's typed in the prompt
      # group functions
      # zle -N history-beginning-search-backward-end history-search-end
      # zle -N history-beginning-search-forward-end history-search-end
      # bindkey "^[OA" history-beginning-search-backward-end
      # bindkey "^[OB" history-beginning-search-forward-end

      # case insensitive tab completion
      zstyle ':completion:*' completer _complete _ignored _approximate
      zstyle ':completion:*' list-colors '\'
      zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
      zstyle ':completion:*' verbose true
      _comp_options+=(globdots)
      # ${lib.optionalString config.services.gpg-agent.enable ''
      #   gnupg_path=$(ls $XDG_RUNTIME_DIR/gnupg)
      #   export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/$gnupg_path/S.gpg-agent.ssh"
      # ''}
      command_not_found_handler() {
        ${pkgs.comma}/bin/comma "$@"
      }
      [ -f "$HOME/.config/shell/pprofile" ] && source "$HOME/.config/shell/pprofile"
    '';
    envExtra = ''
      [ -f "$HOME/.config/shell/pprofile" ] && source "$HOME/.config/shell/pprofile"
    '';
    shellAliases = {
      grep = "grep --color";
      ip = "ip --color";
      l = "eza -l";
      la = "eza -la";
      md = "mkdir -p";
      abook = "abook --config $XDG_CONFIG_HOME/abook/abookrc --datafile $HOME/Documents/abook/addressbook";

      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gca = "git commit --amend";
      gcm = "git commit -m";
      gco = "git checkout";
      gd = "git diff";
      gds = "git diff --staged";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpl = "git pull";
      gl = "git log";
      gr = "git rebase";
      gs = "git status --short";
      gss = "git status";

      us = "systemctl --user";
      rs = "sudo systemctl";
    };
    shellGlobalAliases = { eza = "eza --icons --git"; };
  };
}

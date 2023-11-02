{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasRipgrep = hasPackage "ripgrep";
  hasEza = hasPackage "eza";
  hasNeovim = config.programs.neovim.enable;
  hasEmacs = config.programs.emacs.enable;
  hasNeomutt = config.programs.neomutt.enable;
  hasShellColor = config.programs.shellcolor.enable;
  hasKitty = config.programs.kitty.enable;
  shellcolor = "${pkgs.shellcolord}/bin/shellcolor";
in
{
  programs.fish = {
    enable = true;
    shellAbbrs = rec {
      jqless = "jq -C | less -r";

      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

      nr = "nixos-rebuild --flake .";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

      ls = mkIf hasEza "eza";

      e = mkIf hasEmacs "emacsclient -t";

      vrg = mkIf (hasNeomutt && hasRipgrep) "nvimrg";
      vim = mkIf hasNeovim "nvim";
      vi = vim;
      v = vim;

      mutt = mkIf hasNeomutt "neomutt";
      m = mutt;

      cik = mkIf hasKitty "clone-in-kitty --type os-window";
      ck = cik;
    };
    shellAliases = {
      # Get ip
      getip = "curl ifconfig.me";
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
    };
    functions = {
      fish_greeting = "";
      wh = "readlink -f (which $argv)";
      nvimrg = mkIf (hasNeomutt && hasRipgrep) "nvim -q (rg --vimgrep $argv | psub)";
      # Merge history upon doing up-or-search
      # This lets multiple fish instances share history
      up-or-search = /* fish */ ''
        if commandline --search-mode
          commandline -f history-search-backward
          return
        end
        if commandline --paging-mode
          commandline -f up-line
          return
        end
        set -l lineno (commandline -L)
        switch $lineno
          case 1
            commandline -f history-search-backward
            history merge
          case '*'
            commandline -f up-line
        end
      '';
      # Integrate ssh with shellcolord
      ssh = mkIf hasShellColor ''
        ${shellcolor} disable $fish_pid
        # Check if kitty is available
        if set -q KITTY_PID && set -q KITTY_WINDOW_ID && type -q -f kitty
          kitty +kitten ssh $argv
        else
          command ssh $argv
        end
        ${shellcolor} enable $fish_pid
        ${shellcolor} apply $fish_pid
      '';
      k3s-fetch-merge-config = ''
        set host $argv[1]
        set target $argv[2]
        echo "Updating target $target with config from $host"
        set rconfig (ssh $host "sudo cat /etc/rancher/k3s/k3s.yaml | yq -c")
        set cert_auth_data (echo $rconfig | ${pkgs.jq}/bin/jq -r '.clusters[0].cluster."certificate-authority-data"')
        set client_cert_data (echo $rconfig | ${pkgs.jq}/bin/jq -r '.users[0].user."client-certificate-data"')
        set client_key_data (echo $rconfig | ${pkgs.jq}/bin/jq -r '.users[0].user."client-key-data"')
        set lconfig (cat $HOME/.kube/config | ${pkgs.yq}/bin/yq -c)
        echo "Moving $HOME/.kube/config to $HOME/.kube/config.bak"
        mv $HOME/.kube/config $HOME/.kube/config.bak
        echo "Writing new config to $HOME/.kube/config"
        echo $lconfig \
          | ${pkgs.jq}/bin/jq "(.clusters[] | select(.name == \"$target\")).cluster.\"certificate-authority-data\" |= \"$cert_auth_data\"" \
          | ${pkgs.jq}/bin/jq "(.users[] | select(.name == \"$target-admin\")).user.\"client-certificate-data\" |= \"$client_cert_data\"" \
          | ${pkgs.jq}/bin/jq "(.users[] | select(.name == \"$target-admin\")).user.\"client-key-data\" |= \"$client_key_data\"" \
          | ${pkgs.yq}/bin/yq --yaml-output \
          > $HOME/.kube/config
      '';
    };
    interactiveShellInit =
      # Open command buffer in vim when alt+e is pressed
      ''
        bind \ee edit_command_buffer
      '' +
      # kitty integration
      ''
        set --global KITTY_INSTALLATION_DIR "${pkgs.kitty}/lib/kitty"
        set --global KITTY_SHELL_INTEGRATION enabled
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
      '' +
      '' source /var/run/secrets/lukasz-pprofile
      '' +
      # Use vim bindings and cursors
      ''
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
      '' +
      # Use terminal colors
      ''
        set -U fish_color_autosuggestion      brblack
        set -U fish_color_cancel              -r
        set -U fish_color_command             brgreen
        set -U fish_color_comment             brmagenta
        set -U fish_color_cwd                 green
        set -U fish_color_cwd_root            red
        set -U fish_color_end                 brmagenta
        set -U fish_color_error               brred
        set -U fish_color_escape              brcyan
        set -U fish_color_history_current     --bold
        set -U fish_color_host                normal
        set -U fish_color_match               --background=brblue
        set -U fish_color_normal              normal
        set -U fish_color_operator            cyan
        set -U fish_color_param               brblue
        set -U fish_color_quote               yellow
        set -U fish_color_redirection         bryellow
        set -U fish_color_search_match        'bryellow' '--background=brblack'
        set -U fish_color_selection           'white' '--bold' '--background=brblack'
        set -U fish_color_status              red
        set -U fish_color_user                brgreen
        set -U fish_color_valid_path          --underline
        set -U fish_pager_color_completion    normal
        set -U fish_pager_color_description   yellow
        set -U fish_pager_color_prefix        'white' '--bold' '--underline'
        set -U fish_pager_color_progress      'brwhite' '--background=cyan'
        ${lib.optionalString config.programs.foot.enable ''
        function update_cwd_osc --on-variable PWD --description 'Notify terminals when $PWD changes'
            if status --is-command-substitution || set -q INSIDE_EMACS
                return
            end
            printf \e\]7\;file://%s%s\e\\ $hostname (string escape --style=url $PWD)
        end

        update_cwd_osc # Run once since we might have inherited PWD from a parent shell
        function mark_prompt_start --on-event fish_prompt
            echo -en "\e]133;A\e\\"
        end
        ''}
      '';
  };
}

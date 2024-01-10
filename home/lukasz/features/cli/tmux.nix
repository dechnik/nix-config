{ config
, pkgs
, ...
}:
let
  sessionx = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "sessionx";
    version = "unstable-2024-01-03";
    src = pkgs.fetchFromGitHub {
      owner = "omerxx";
      repo = "tmux-sessionx";
      rev = "a87122c8f4bd2eb19c3ae556e2aad2973e2ca37c";
      sha256 = "sha256-/VZyEIxqIn0ISgZ6u5TcYcXWRE+6SDK5JK1W34lKIKk=";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postPatch = ''
      substituteInPlace sessionx.tmux \
        --replace "\$CURRENT_DIR/scripts/sessionx.sh" "$out/share/tmux-plugins/sessionx/scripts/sessionx.sh"
      substituteInPlace scripts/sessionx.sh \
        --replace "/tmux-sessionx/scripts/preview.sh" "$out/share/tmux-plugins/sessionx/scripts/preview.sh"
    '';

    postInstall = ''
      chmod +x $target/scripts/sessionx.sh
      wrapProgram $target/scripts/sessionx.sh \
        --prefix PATH : ${with pkgs; lib.makeBinPath [ tmuxPlugins.tmux-fzf gnugrep gnused coreutils ]}
      chmod +x $target/scripts/preview.sh
      wrapProgram $target/scripts/preview.sh \
        --prefix PATH : ${with pkgs; lib.makeBinPath [ coreutils gnugrep gnused ]}
    '';
  };
in
{
  programs.tmux = {
    enable = true;
    shell = "${config.programs.fish.package}/bin/fish";
    # terminal = "screen-256color";
    clock24 = true;
    baseIndex = 1;
    escapeTime = 0;
    secureSocket = true;
    historyLimit = 30000;

    sensibleOnTop = false;

    tmuxinator.enable = true;
    plugins = with pkgs; [
      sessionx
      tmuxPlugins.tmux-fzf
      tmuxPlugins.yank
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];

    extraConfig = ''
      color_status_text="colour245"
      color_window_off_status_bg="colour238"
      color_light="white" #colour015
      color_dark="colour232" # black= colour232
      color_window_off_status_current_bg="colour254"
      set -as terminal-overrides ",gnome*:Tc"
      new-session -n $HOST
      # colon :
      bind : command-prompt
      # split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      unbind '"'
      unbind %
      # Pane switching
      bind -n M-Tab selectp -t :.+
      bind -n M-S-Tab selectp -t :.-
      # Mouse
      set -g mouse on
      # panes
      set -g pane-border-style fg=black
      set -g pane-active-border-style fg=brightred
      # status line
      set -g status-justify "left"
      set -g status-style bg=default,fg=colour12
      set -g status-interval 2
      # messaging
      set -g message-style fg=black,bg=yellow
      set -g message-command-style fg=blue,bg=black
      # C-b is not acceptable -- Vim uses it
      set-option -g prefix C-a
      bind-key C-a last-window
      # hjkl pane traversal
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      #window mode
      setw -g mode-style bg=colour6,fg=colour0
      bind -T root F12  \
        set prefix None \;\
        set key-table off \;\
        set status-style "fg=$color_status_text,bg=$color_window_off_status_bg" \;\
        set window-status-current-format "#[fg=$color_window_off_status_bg,bg=$color_window_off_status_current_bg]$separator_powerline_right#[default] #I:#W# #[fg=$color_window_off_status_current_bg,bg=$color_window_off_status_bg]$separator_powerline_right#[default]" \;\
        set window-status-current-style "fg=$color_dark,bold,bg=$color_window_off_status_current_bg" \;\
        if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
        refresh-client -S \;\
      bind -T off F12 \
        set -u prefix \;\
        set -u key-table \;\
        set -u status-style \;\
        set -u window-status-current-style \;\
        set -u window-status-current-format \;\
        refresh-client -S
      # The statusbar {
      set -g status-position bottom
      set -g status-style bg=colour234,fg=colour137,dim
      set -g status-left ""
      wg_is_keys_off="#[fg=$color_light,bg=$color_window_off_indicator]#([ $(tmux show-option -qv key-table) = 'off' ] && echo 'OFF')#[default]"
      set -g status-right "$wg_is_keys_off"
      set -g status-right-length 50
      set -g status-left-length 20
      setw -g window-status-current-style fg=colour81,bg=colour238,bold
      setw -g window-status-current-format " #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F "
      setw -g window-status-style bg=colour235,fg=colour138,none
      setw -g window-status-format " #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F "
      # setw -g window-status-bell-style bg=colour1,fg=colour255,bold
      # }
      # loud or quiet?
      set-option -g visual-activity off
      set-option -g visual-bell on
      set-option -g visual-silence off
      set-window-option -g monitor-activity off
      set-option -g bell-action any
      set -g renumber-windows on       # renumber all windows when any window is closed
      set -g set-clipboard on          # use system clipboard
      set -g @sessionx-bind o
    '';
  };
}

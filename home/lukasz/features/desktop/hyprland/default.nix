{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    ../common
    ../common/wayland-wm
    # ./tty-init.nix
    ./basic-binds.nix
    # ./systemd-fixes.nix
  ];

  xdg.portal = {
    extraPortals = [ pkgs.inputs.hyprland.xdg-desktop-portal-hyprland ];
    configPackages = [ config.wayland.windowManager.hyprland.package ];
  };

  home.packages = with pkgs; [
    inputs.hyprwm-contrib.packages.${system}.grimblast
    swaybg
    swayidle
    nwg-displays
    wlr-randr
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };
    settings = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 1;
        cursor_inactive_timeout = 4;
        "col.active_border" = "0xff${config.colorscheme.palette.base0C}";
        "col.inactive_border" = "0xff${config.colorscheme.palette.base02}";
      };
      group = {
        "col.border_active" = "0xff${config.colorscheme.palette.base0B}";
        "col.border_inactive" = "0xff${config.colorscheme.palette.base04}";
      };
      input = {
        kb_layout = "pl";
        repeat_rate = 60;
        repeat_delay = 250;
        touchpad.disable_while_typing = false;
      };
      dwindle.split_width_multiplier = 1.35;
      misc = {
        vfr = true;
        force_default_wallpaper = 0;
      };
      windowrulev2 = [
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"
      ];
      layerrule = [
        "blur,waybar"
        "ignorezero,waybar"
      ];
      decoration = {
        # active_opacity = 0.94;
        # inactive_opacity = 0.84;
        # fullscreen_opacity = 1.0;
        rounding = 0;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
        drop_shadow = true;
        shadow_range = 12;
        shadow_offset = "3 3";
        "col.shadow" = "0x44000000";
        "col.shadow_inactive" = "0x66000000";
      };
      animations = {
        enabled = true;
        bezier = [
          "easein,0.11, 0, 0.5, 0"
          "easeout,0.5, 1, 0.89, 1"
          "easeinback,0.36, 0, 0.66, -0.56"
          "easeoutback,0.34, 1.56, 0.64, 1"
        ];

        animation = [
          "windowsIn,1,3,easeoutback,slide"
          "windowsOut,1,3,easeinback,slide"
          "windowsMove,1,3,easeoutback"
          "workspaces,1,2,easeoutback,slide"
          "fadeIn,1,3,easeout"
          "fadeOut,1,3,easein"
          "fadeSwitch,1,3,easeout"
          "fadeShadow,1,3,easeout"
          "fadeDim,1,3,easeout"
          "border,1,3,easeout"
        ];
      };
      exec = [
        "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"
      ];
      bind = let
        swaylock = "${config.programs.swaylock.package}/bin/swaylock";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";
        playerctld = "${config.services.playerctld.package}/bin/playerctld";
        makoctl = "${config.services.mako.package}/bin/makoctl";
        wofi = "${config.programs.wofi.package}/bin/wofi";
        pass-wofi = "${pkgs.pass-wofi.override {
          pass = config.programs.password-store.package;
        }}/bin/pass-wofi";

        grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
        pactl = "${pkgs.pulseaudio}/bin/pactl";

        gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
        xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
        defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

        terminal = config.home.sessionVariables.TERMINAL;
        browser = defaultApp "x-scheme-handler/https";
        editor = defaultApp "text/plain";
      in [
        # Program bindings
        "SUPER,r,exec,$TERMINAL $SHELL -ic yazi"
        "SUPER,Return,exec,${terminal}"
        "SUPERSHIFT,Return,exec,${terminal} -e tmux new tmux-sessionizer"
        "SUPER,e,exec,${editor}"
        "SUPER,v,exec,${editor}"
        "SUPER,w,exec,${browser}"

        # Lock screen
        "SUPER,Escape,exec,wlogout -p layer-shell"

        "SUPERSHIFT,s,exec,spicemenu"
        # Brightness control (only works if the system has lightd)
        ",XF86MonBrightnessUp,exec,light -A 10"
        ",XF86MonBrightnessDown,exec,light -U 10"
        # Volume
        ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        # Screenshotting
        ",Print,exec,${grimblast} --notify copy output"
        "SHIFT,Print,exec,${grimblast} --notify copy active"
        "CONTROL,Print,exec,${grimblast} --notify copy screen"
        "SUPER,Print,exec,${grimblast} --notify copy window"
        "ALT,Print,exec,${grimblast} --notify copy area"
      ] ++
      (lib.optionals config.services.playerctld.enable [
        # Media control
        ",XF86AudioNext,exec,${playerctl} next"
        ",XF86AudioPrev,exec,${playerctl} previous"
        ",XF86AudioPlay,exec,${playerctl} play-pause"
        ",XF86AudioStop,exec,${playerctl} stop"
        "ALT,XF86AudioNext,exec,${playerctld} shift"
        "ALT,XF86AudioPrev,exec,${playerctld} unshift"
        "ALT,XF86AudioPlay,exec,systemctl --user restart playerctld"
      ]) ++
      # Screen lock
      (lib.optionals config.programs.swaylock.enable [
        ",XF86Launch4,exec,${swaylock} -i ${config.wallpaper} --grace 2"
        "SUPERSHIFT,Escape,exec,${swaylock} -i ${config.wallpaper} --grace 2"
      ]) ++
      # Notification manager
      (lib.optionals config.services.mako.enable [
        "SUPER,w,exec,${makoctl} dismiss"
      ]) ++
      # Launcher
      (lib.optionals config.programs.wofi.enable [
        "SUPER,x,exec,${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
        "SUPER,d,exec,${wofi} -S run,drun"
      ] ++ (lib.optionals config.programs.password-store.enable [
        ",Scroll_Lock,exec,${pass-wofi}" # fn+k
        ",XF86Calculator,exec,${pass-wofi}" # fn+f12
        "SUPER,semicolon,exec,pass-wofi"
      ]));

      # monitor = map (m: let
      #   resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
      #   position = "${toString m.x}x${toString m.y}";
      # in
      #   "${m.name},${if m.enabled then "${resolution},${position},1" else "disable"}"
      # ) (config.monitors);

      # workspace = map (m:
      #   "${m.name},${m.workspace}"
      # ) (lib.filter (m: m.enabled && m.workspace != null) config.monitors);
    };
    extraConfig = ''
      source = ~/.config/hypr/monitors.conf
      source = ~/.config/hypr/workspaces.conf
      # make Firefox PiP window floating and sticky
      windowrulev2 = float, title:^(Picture-in-Picture)$
      windowrulev2 = pin, title:^(Picture-in-Picture)$

      # throw sharing indicators away
      windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
      windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$
      # idle inhibit while watching videos
      windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
      windowrulev2 = idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$
      windowrulev2 = idleinhibit fullscreen, class:^(firefox)$
      # fix xwayland apps
      # windowrulev2 = center, class:^(.*jetbrains.*)$, title:^(Confirm Exit|Open Project|win424|win201|splash)$
      # windowrulev2 = size 640 400, class:^(.*jetbrains.*)$, title:^(splash)$
    '';
  };
}

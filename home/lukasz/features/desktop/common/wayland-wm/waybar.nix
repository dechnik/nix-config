{
  outputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  neomutt = "${pkgs.neomutt}/bin/neomutt";
  ikhal = "${pkgs.khal}/bin/ikhal";

  terminal = "${pkgs.kitty}/bin/kitty";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

  calendar = terminal-spawn ikhal;
  mail = terminal-spawn neomutt;

  commonDeps = with pkgs; [
    coreutils
    gnugrep
    systemd
  ];
  # Function to simplify making waybar outputs
  mkScript =
    {
      name ? "script",
      deps ? [ ],
      script ? "",
    }:
    lib.getExe (
      pkgs.writeShellApplication {
        inherit name;
        text = script;
        runtimeInputs = commonDeps ++ deps;
      }
    );
  # Specialized for JSON outputs
  mkScriptJson =
    {
      name ? "script",
      deps ? [ ],
      script ? "",
      text ? "",
      tooltip ? "",
      alt ? "",
      class ? "",
      percentage ? "",
    }:
    mkScript {
      inherit name;
      deps = [ pkgs.jq ] ++ deps;
      script = ''
        ${script}
        jq -cn \
          --arg text "${text}" \
          --arg tooltip "${tooltip}" \
          --arg alt "${alt}" \
          --arg class "${class}" \
          --arg percentage "${percentage}" \
          '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
      '';
    };
  swayCfg = config.wayland.windowManager.sway;
  hyprlandCfg = config.wayland.windowManager.hyprland;
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = true;
    settings = {
      secondary = {
        mode = "dock";
        layer = "top";
        height = 34;
        margin = "0";
        position = "top";
        output = builtins.map (m: m.name) (builtins.filter (m: !m.isPrimary) config.monitors);
        modules-left =
          (lib.optionals config.wayland.windowManager.sway.enable [
            "sway/workspaces"
            "sway/mode"
          ])
          ++ (lib.optionals config.wayland.windowManager.hyprland.enable [
            "hyprland/workspaces"
            "hyprland/submap"
          ])
          ++ [
            # "custom/currentplayer"
            # "custom/player"
          ];
        modules-center = [ "clock" ];

        clock = {
          format = "{:%d/%m %H:%M}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };
        "wlr/workspaces" = {
          on-click = "activate";
          format = "{name}";
          sort-by-name = true;
        };
      };
      primary = {
        mode = "dock";
        layer = "top";
        height = 34;
        margin = "0";
        position = "top";
        output = builtins.map (m: m.name) (builtins.filter (m: m.isPrimary) config.monitors);
        modules-left =
          (lib.optionals config.wayland.windowManager.sway.enable [
            "sway/workspaces"
            "sway/mode"
          ])
          ++ (lib.optionals config.wayland.windowManager.hyprland.enable [
            "hyprland/workspaces"
            "hyprland/submap"
          ])
          ++ [
            "custom/currentplayer"
            "custom/player"
          ];
        modules-center = [
          "pulseaudio"
          "battery"
          "clock"
          "custom/gpg-agent"
          "custom/unread-mail"
        ];
        modules-right = [
          "network"
          "tray"
          "custom/hostname"
        ];

        "wlr/workspaces" = {
          on-click = "activate";
          format = "{name}";
          sort-by-name = true;
        };
        clock = {
          format = "{:%d/%m %H:%M}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          on-click = calendar;
        };
        cpu = {
          format = "   {usage}%";
        };
        "custom/gpu" = {
          interval = 5;
          exec = mkScript { script = "cat /sys/class/drm/card*/device/gpu_busy_percent | head -1"; };
          format = "󰒋  {}%";
        };
        memory = {
          format = "󰍛  {}%";
          interval = 5;
        };
        pulseaudio = {
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭 0%";
          format = "{icon} {volume}% {format_source}";
          format-muted = "󰸈 0% {format_source}";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = lib.getExe pkgs.pavucontrol;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };
        "sway/window" = {
          max-length = 20;
        };
        network = {
          interval = 3;
          format-wifi = "   {essid}";
          format-ethernet = "󰈁 Connected";
          format-disconnected = "";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          on-click = "";
        };
        "custom/menu" = {
          interval = 1;
          return-type = "json";
          exec = mkScriptJson {
            deps = lib.optional hyprlandCfg.enable hyprlandCfg.package;
            text = "";
            tooltip = ''$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)'';
            class =
              let
                isFullScreen =
                  if hyprlandCfg.enable then "hyprctl activewindow -j | jq -e '.fullscreen' &>/dev/null" else "false";
              in
              "$(if ${isFullScreen}; then echo fullscreen; fi)";
          };
        };
        "custom/hostname" = {
          exec = mkScript {
            script = ''
              echo "$USER@$HOSTNAME"
            '';
          };
          on-click = mkScript {
            script = ''
              systemctl --user restart waybar
            '';
          };
        };
        "custom/gpg-agent" = {
          interval = 2;
          return-type = "json";
          exec =
            let
              keyring = import ../../../trusted/keyring.nix { inherit pkgs; };
            in
            mkScriptJson {
              deps = [ pkgs.playerctl ];
              script = ''
                status=$(${keyring.isUnlocked} && echo "unlocked" || echo "locked")
              '';
              alt = "$status";
              tooltip = "GPG is $status";
            };
          format = "{icon}";
          format-icons = {
            "locked" = "";
            "unlocked" = "";
          };
          on-click = "";
        };
        "custom/unread-mail" = {
          interval = 60;
          return-type = "json";
          exec = mkScriptJson {
            deps = [
              pkgs.findutils
              pkgs.perl
              pkgs.xmlstarlet
              pkgs.gnused
              pkgs.procps
            ];
            script = ''
              count=$(find ~/.local/share/mail/*/Inbox/new -type f | wc -l)
              if [ "$count" == "0" ]; then
                subjects="No new mail"
                status="read"
              else
                subjects=$(\
                  grep -h "Subject: " -r ~/.local/share/mail/*/Inbox/new | cut -d ':' -f2- | \
                  perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | xml esc | sed -e 's/^/\-/'\
                )
                status="unread"
              fi
              if pgrep mbsync &>/dev/null; then
                status="syncing"
              fi
            '';
            text = "$count";
            tooltip = "$subjects";
            alt = "$status";
          };
          format = "{icon}  {}";
          format-icons = {
            "read" = "󰇯";
            "unread" = "󰇮";
            "syncing" = "󰁪";
          };
          on-click = mail;
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = mkScriptJson {
            deps = [ pkgs.playerctl ];
            script = ''
              all_players=$(playerctl -l 2>/dev/null)
              selected_player="$(playerctl status -f "{{playerName}}" 2>/dev/null || true)"
              clean_player="$(echo "$selected_player" | cut -d '.' -f1)"
            '';
            alt = "$clean_player";
            tooltip = "$all_players";
          };
          format = "{icon}{}";
          format-icons = {
            "" = " ";
            "Celluloid" = "󰎁 ";
            "spotify" = "󰓇 ";
            "ncspot" = "󰓇 ";
            "qutebrowser" = "󰖟 ";
            "firefox" = " ";
            "discord" = " 󰙯 ";
            "sublimemusic" = " ";
            "kdeconnect" = "󰄡 ";
            "chromium" = " ";
          };
        };
        "custom/player" = {
          exec-if = mkScript {
            deps = [ pkgs.playerctl ];
            script = ''
              selected_player="$(playerctl status -f "{{playerName}}" 2>/dev/null || true)"
              playerctl status -p "$selected_player" 2>/dev/null
            '';
          };
          exec = mkScript {
            deps = [ pkgs.playerctl ];
            script = ''
              selected_player="$(playerctl status -f "{{playerName}}" 2>/dev/null || true)"
              playerctl metadata -p "$selected_player" \
                --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{artist}} - {{title}} ({{album}})"}' 2>/dev/null
            '';
          };
          return-type = "json";
          interval = 2;
          escape = true;
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤 ";
            "Stopped" = "󰓛";
          };
          on-click = mkScript {
            deps = [ pkgs.playerctl ];
            script = "playerctl play-pause";
          };
        };
      };

    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style =
      let
        inherit (config.colorscheme) palette;
      in
      # css
      ''
        * {
          transition: none;
          box-shadow: none;
        }

        #waybar {
          font-family: ${config.fontProfiles.regular.name}, ${config.fontProfiles.monospace.name};
          font-size: 10pt;
          color: #${palette.base04};
          background: #${palette.base01};
        }
        #workspaces {
          margin: 0 4px;
        }

        #workspaces button {
          margin: 4px 0;
          padding: 0 4px;
          color: #${palette.base05};
        }

        #workspaces button.visible {
        }

        #workspaces button.active {
          border-radius: 0px;
          background-color: #${palette.base02};
        }

        #workspaces button.urgent {
          color: rgba(238, 46, 36, 1);
        }

        #tray {
          margin: 4px 4px 4px 4px;
          border-radius: 0px;
          background-color: #${palette.base02};
        }

        #tray * {
          padding: 0 6px;
          border-left: 1px solid #${palette.base00};
        }

        #tray *:first-child {
          border-left: none;
        }

        #mode, #battery, #cpu, #memory, #network, #pulseaudio, #idle_inhibitor, #backlight, #custom-gammastep, #custom-gpg-agent, #custom-unread-mail, #custom-tailscale-ping, #custom-storage, #custom-updates, #custom-weather, #custom-mail, #clock, #temperature  {
          margin: 4px 2px;
          padding: 0 6px;
          background-color: #${palette.base02};
          border-radius: 0px;
          min-width: 20px;
        }

        #pulseaudio.muted {
          color: #${palette.base0F};
        }

        #pulseaudio.bluetooth {
          color: #${palette.base0C};
        }

        #clock {
          margin-left: 0px;
          margin-right: 4px;
          background-color: transparent;
        }
        #custom-hostname {
          margin-left: 0px;
          margin-right: 4px;
          background-color: transparent;
        }

        #temperature.critical {
          color: #${palette.base0F};
        }

        #window {
          font-size: 0.9em;
          font-weight: 400;
          font-family: sans-serif;
        }
      '';
  };
}

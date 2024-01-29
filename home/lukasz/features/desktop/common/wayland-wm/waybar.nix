{ outputs, config, lib, pkgs, ... }:

let
  # Dependencies
  cat = "${pkgs.coreutils}/bin/cat";
  cut = "${pkgs.coreutils}/bin/cut";
  find = "${pkgs.findutils}/bin/find";
  grep = "${pkgs.gnugrep}/bin/grep";
  perl = "${pkgs.perl}/bin/perl";
  pgrep = "${pkgs.procps}/bin/pgrep";
  sed = "${pkgs.gnused}/bin/sed";
  tail = "${pkgs.coreutils}/bin/tail";
  wc = "${pkgs.coreutils}/bin/wc";
  xargs = "${pkgs.findutils}/bin/xargs";
  timeout = "${pkgs.coreutils}/bin/timeout";
  ping = "${pkgs.iputils}/bin/ping";

  jq = "${pkgs.jq}/bin/jq";
  xml = "${pkgs.xmlstarlet}/bin/xml";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  gamemoded = "${pkgs.gamemode}/bin/gamemoded";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  neomutt = "${pkgs.neomutt}/bin/neomutt";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  btm = "${pkgs.bottom}/bin/btm";
  wofi = "${pkgs.wofi}/bin/wofi";
  # TODO enable when https://github.com/NixOS/nixpkgs/issues/263504 resolved
  # ikhal = "${pkgs.khal}/bin/ikhal";

  terminal = "${pkgs.kitty}/bin/kitty";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

  # calendar = terminal-spawn ikhal;
  systemMonitor = terminal-spawn btm;
  mail = terminal-spawn neomutt;

  # Function to simplify making waybar outputs
  jsonOutput = name: { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? "" }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
    set -euo pipefail
    ${pre}
    ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
  ''}/bin/waybar-${name}";
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or  [ ]) ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = true;
    settings = {
      primary = {
        mode = "dock";
        layer = "top";
        height = 34;
        margin = "0";
        position = "top";
        output = builtins.map (m: m.name) (builtins.filter (m: m.isPrimary) config.monitors);
        modules-left = (lib.optionals config.wayland.windowManager.sway.enable [
          "sway/workspaces"
          "sway/mode"
        ]) ++ (lib.optionals config.wayland.windowManager.hyprland.enable [
          "hyprland/workspaces"
          "hyprland/submap"
        ]) ++ [
          # "custom/currentplayer"
          # "custom/player"
        ];
        modules-center = [
          "pulseaudio"
          "battery"
          "clock"
          "custom/gpg-agent"
          "custom/unread-mail"
        ];
        modules-right = [
          # "custom/gamemode"
          "network"
          "custom/tailscale-ping"
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
          # on-click = calendar;
        };
        cpu = {
          format = "   {usage}%";
          on-click = systemMonitor;
        };
        "custom/gpu" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gpu" {
            text = "$(${cat} /sys/class/drm/card0/device/gpu_busy_percent)";
            tooltip = "GPU Usage";
          };
          format = "󰒋  {}%";
        };
        memory = {
          format = "󰍛  {}%";
          interval = 5;
          on-click = systemMonitor;
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = [ "" "" "" ];
          };
          on-click = pavucontrol;
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
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
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
        "custom/tailscale-ping" = {
          interval = 10;
          return-type = "json";
          exec =
            let
              inherit (builtins) concatStringsSep attrNames replaceStrings;
              hosts = attrNames outputs.nixosConfigurations;
              homeMachine = "bolek_pve";
              remoteMachine = "tolek_oracle";
              mailMachine = "ola_hetzner";
            in
            jsonOutput "tailscale-ping" {
              # Build variables for each host
              pre = ''
                set -o pipefail
                ${concatStringsSep "\n" (map (host: ''
                  ping_${replaceStrings ["."] ["_"] host}="$(${timeout} 2 ${ping} -c 1 -q ${host} 2>/dev/null | ${tail} -1 | ${cut} -d '/' -f5 | ${cut} -d '.' -f1)ms" || ping_${replaceStrings ["."] ["_"] host}="Dc"
                '') hosts)}
              '';
              # Access a remote machine's and a home machine's ping
              text = "  $ping_${remoteMachine}   $ping_${mailMachine}   $ping_${homeMachine}";
              # Show pings from all machines
              tooltip = concatStringsSep "\n" (map (host: "${host}: $ping_${replaceStrings ["."] ["_"] host}") hosts);
            };
          format = "{}";
          on-click = "";
        };
        "custom/menu" = {
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
            tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)'';
          };
          on-click = "${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";
        };
        "custom/hostname" = {
          exec = "echo $USER@$HOSTNAME";
        };
        "custom/gpg-agent" = {
          interval = 2;
          return-type = "json";
          exec =
            let keyring = import ../../../trusted/keyring.nix { inherit pkgs; };
            in
            jsonOutput "gpg-agent" {
              pre = ''status=$(${keyring.isUnlocked} && echo "unlocked" || echo "locked")'';
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
          exec = jsonOutput "unread-mail" {
            pre = ''
              count=$(${find} ~/.local/share/mail/*/Inbox/new -type f | ${wc} -l)
              if [ "$count" == "0" ]; then
                subjects="No new mail"
                status="read"
              else
                subjects=$(\
                  ${grep} -h "Subject: " -r ~/.local/share/mail/*/Inbox/new | ${cut} -d ':' -f2- | \
                  ${perl} -CS -MEncode -ne 'print decode("MIME-Header", $_)' | ${xml} esc | ${sed} -e 's/^/\-/'\
                )
                status="unread"
              fi
              if ${pgrep} mbsync &>/dev/null; then
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
        "custom/gamemode" = {
          exec-if = "${gamemoded} --status | ${grep} 'is active' -q";
          interval = 2;
          return-type = "json";
          exec = jsonOutput "gamemode" {
            tooltip = "Gamemode is active";
          };
          format = " ";
        };
        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gammastep" {
            pre = ''
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
                status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | ${tail} -1 | ${cut} -d ':' -f6 | ${xargs}))"
              else
                status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
          format-icons = {
            "activating" = "󰁪 ";
            "deactivating" = "󰁪 ";
            "inactive" = "? ";
            "active (Night)" = " ";
            "active (Nighttime)" = " ";
            "active (Transition (Night)" = " ";
            "active (Transition (Nighttime)" = " ";
            "active (Day)" = " ";
            "active (Daytime)" = " ";
            "active (Transition (Day)" = " ";
            "active (Transition (Daytime)" = " ";
          };
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep";
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            pre = ''
              player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active" | ${cut} -d '.' -f1)"
              count="$(${playerctl} -l 2>/dev/null | ${wc} -l)"
              if ((count > 1)); then
                more=" +$((count - 1))"
              else
                more=""
              fi
            '';
            alt = "$player";
            tooltip = "$player ($count available)";
            text = "$more";
          };
          format = "{icon}{}";
          format-icons = {
            "No player active" = " ";
            "Celluloid" = "󰎁 ";
            "spotify" = " 󰓇";
            "ncspot" = " 󰓇";
            "qutebrowser" = "󰖟";
            "firefox" = " ";
            "brave" = " ";
            "discord" = "  ";
            "sublimemusic" = " ";
            "kdeconnect" = "󰄡 ";
          };
          on-click = "${playerctld} shift";
          on-click-right = "${playerctld} unshift";
        };
        "custom/player" = {
          exec-if = "${playerctl} status 2>/dev/null";
          exec = ''${playerctl} metadata --format '{"text": "{{title}} - {{artist}}", "alt": "{{status}}", "tooltip": "{{title}} - {{artist}} ({{album}})"}' 2>/dev/null '';
          return-type = "json";
          interval = 2;
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤 ";
            "Stopped" = "󰓛";
          };
          on-click = "${playerctl} play-pause";
        };
      };

    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let inherit (config.colorscheme) colors; in /* css */ ''
      * {
        transition: none;
        box-shadow: none;
      }

      #waybar {
        font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
        font-size: 1.2em;
        font-weight: 400;
        color: #${colors.base04};
        background: #${colors.base01};
      }
      #workspaces {
        margin: 0 4px;
      }

      #workspaces button {
        margin: 4px 0;
        padding: 0 4px;
        color: #${colors.base05};
      }

      #workspaces button.visible {
      }

      #workspaces button.active {
        border-radius: 4px;
        background-color: #${colors.base02};
      }

      #workspaces button.urgent {
        color: rgba(238, 46, 36, 1);
      }

      #tray {
        margin: 4px 4px 4px 4px;
        border-radius: 4px;
        background-color: #${colors.base02};
      }

      #tray * {
        padding: 0 6px;
        border-left: 1px solid #${colors.base00};
      }

      #tray *:first-child {
        border-left: none;
      }

      #mode, #battery, #cpu, #memory, #network, #pulseaudio, #idle_inhibitor, #backlight, #custom-gammastep, #custom-gpg-agent, #custom-unread-mail, #custom-tailscale-ping, #custom-storage, #custom-updates, #custom-weather, #custom-mail, #clock, #temperature  {
        margin: 4px 2px;
        padding: 0 6px;
        background-color: #${colors.base02};
        border-radius: 4px;
        min-width: 20px;
      }

      #pulseaudio.muted {
        color: #${colors.base0F};
      }

      #pulseaudio.bluetooth {
        color: #${colors.base0C};
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
        color: #${colors.base0F};
      }

      #window {
        font-size: 0.9em;
        font-weight: 400;
        font-family: sans-serif;
      }
    '';
  };
}

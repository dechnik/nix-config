{
  config,
  colors,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  _ = lib.getExe;
  dependencies = with pkgs; [
    config.wayland.windowManager.hyprland.package
    wlogout
    libjack2
    coreutils
    wireplumber
    pavucontrol
    gnugrep
    perl
    bash
    gawk
    gnused
    findutils
  ];
  jq = "${pkgs.gojq}/bin/gojq";
  xml = "${pkgs.xmlstarlet}/bin/xml";
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
in {

  # home.file.".config/waybar/scripts" = {
  #   source = ./scripts;
  #   recursive = true;
  # };
  home.packages = dependencies;
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (
      old: {
        src = pkgs.fetchFromGitHub {
          owner = "Alexays";
          repo = "Waybar";
          rev = "0.9.16";
          sha256 = "sha256-hcU0ijWIN7TtIPkURVmAh0kanQWkBUa22nubj7rSfBs=";
        };
        preBuildPhases = ["hyprlandPatch"];
        hyprlandPatch = "sed -i \'s/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = \"hyprctl dispatch workspace \" + name_;\\n\\tsystem(command.c_str());/g\' /build/source/src/modules/wlr/workspace_manager.cpp";
        # mesonFlags = old.mesonFlags ++ ["-Dexperimental=true" "-Djack=disabled"];
        mesonFlags = old.mesonFlags ++ ["-Dexperimental=true"];
      }
    );
    # package = if (osConfig.networking.hostName == "dziad")
    # then pkgs.waybar.overrideAttrs (
    #   old: {
    #     src = pkgs.fetchFromGitHub {
    #       owner = "Alexays";
    #       repo = "Waybar";
    #       rev = "0.9.16";
    #       sha256 = "sha256-hcU0ijWIN7TtIPkURVmAh0kanQWkBUa22nubj7rSfBs=";
    #     };
    #     preBuildPhases = ["hyprlandPatch"];
    #     hyprlandPatch = "sed -i \'s/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = \"hyprctl dispatch workspace \" + name_;\\n\\tsystem(command.c_str());/g\' /build/source/src/modules/wlr/workspace_manager.cpp";
    #     # mesonFlags = old.mesonFlags ++ ["-Dexperimental=true" "-Djack=disabled"];
    #     mesonFlags = old.mesonFlags ++ ["-Dexperimental=true" "-Dwireplumber=disabled"];
    #   }
    # )
    # else if (osConfig.networking.hostName == "ldlat")
    # then pkgs.waybar
    # else pkgs.waybar;
    settings = [
      {
        name = "main-bar";
        id = "main-bar";
        layer = "top";
        mode = "dock";
        exclusive = true;
        passthrough = false;
        position = "top";
        gtk-layer-shell = true;
        height = 24;
        #width = 0;
        #spacing = 6;
        #margin = 0;
        #margin-top = 0;
        #margin-bottom = 0;
        #margin-left = 0;
        #margin-right = 0;
        #fixed-center = true;
        # ipc = true;
        # modules-left = ["wlr/workspaces" "hyprland/window"];
        modules-left = ["wlr/workspaces"];
        # modules-left = if (osConfig.networking.hostName == "ldlat")
        #                then ["sway/workspaces" "sway/mode"]
        #                else ["wlr/workspaces"];
        modules-right = ["custom/unread-mail" "cpu" "memory" "pulseaudio" "network" "clock" "tray"];

        "custom/power" = {
          format = "襤";
          tooltip = false;
          on-click = "${_ pkgs.wlogout} -p layer-shell";
        };
        "wlr/workspaces" = {
          format = "{name}";
          sort-by-name = true;
          on-click = "activate";
          disable-scroll = true;
        };
        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };
        "cpu" = {
          interval = 5;
          format = " LOAD: {usage}%";
        };
        "memory" = {
          interval = 10;
          format = " USED: {used:0.1f}G";
        };
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " Mute";
          format-bluetooth = " {volume}% {format_source}";
          format-bluetooth-muted = " Mute";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          scroll-step = 5.0;
          on-click = "amixer set Master toggle";
          on-click-right = "${_ pkgs.pavucontrol}";
          smooth-scrolling-threshold = 1;
        };
        "network" = {
          interval = 5;
          format-wifi = " {essid}";
          format-ethernet = " {ipaddr}/{cidr}";
          format-linked = " {ifname} (No IP)";
          format-disconnected = "睊 Disconnected";
          format-disabled = "睊 Disabled";
          format-alt = " {bandwidthUpBits} |  {bandwidthDownBits}";
          tooltip-format = " {ifname} via {gwaddr}";
          on-click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        "clock" = {
          interval = 60;
          align = 0;
          rotate = 0;
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          format = " {:%H:%M}";
          format-alt = " {:%a %b %d, %G}";
        };
        "tray" = {
          # icon-size = 12;
          spacing = 10;
        };
        "custom/unread-mail" = {
          interval = 60;
          return-type = "json";
          exec = jsonOutput "unread-mail" {
            pre = ''
              count=$(find ~/.local/share/mail/*/Inbox/new -type f | wc -l)
              if [ "$count" == "0" ]; then
                subjects="No new mail"
                status="read"
              else
                subjects=$(\
                  grep -h "Subject: " -r ~/.local/share/mail/*/Inbox/new | cut -d ':' -f2- | \
                  perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | ${xml} esc | sed -e 's/^/\-/'\
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
          format = "{icon} {}";
          format-icons = {
            "read" = "";
            "unread" = "";
            "syncing" = "";
          };
        };
      }
    ];
    style = let inherit (config.colorscheme) colors; in /* css */ ''
      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: iosevka, Roboto, Helvetica, Arial, sans-serif, "Font Awesome 5 Free";
          font-size: 14px;
      }

      window#waybar {
      /*    background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);*/
          color: #a89984;
          background-color: #282828;
      /*    transition-property: background-color;
          transition-duration: .5s;*/
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      /*
      window#waybar.empty {
          background-color: transparent;
      }
      window#waybar.solo {
          background-color: #FFFFFF;
      }
      */

      /*window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }*/

      #workspaces button {
          padding: 0 10px;
          background-color: #282828;
          color: #ebdbb2;
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each workspace name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      /*    box-shadow: inset 0 -3px #fbf1c7;
      */
          background-color: #3c3836;
      }

      #workspaces button.active {
      /*    box-shadow: inset 0 -3px #fbf1c7;
      */
          background-color: #3c3836;
          color: #ebdbb2;
      }
      #workspaces button.focused {
      /*    box-shadow: inset 0 -3px #fbf1c7;
      */
          background-color: #3c3836;
          color: #ebdbb2;
      }

      #workspaces button.urgent {
          background-color: #fbf1c7;
          color: #3c3836;
      }

      #mode {
          background-color: #64727D;
          border-bottom: 3px solid #fbf1c7;
      }

      #clock,
      #battery,
      #cpu,
      #custom-mail,
      #custom-unread-mail,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #custom-poweroff,
      #custom-suspend,
      #mpd {
          padding: 0 10px;
          background-color: #282828;
          color: #ebdbb2;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          color: #8ec07c;
      }

      #battery {
          color: #d3869b;
      }

      #battery.charging, #battery.plugged {
          color: #d3869b;
      }

      @keyframes blink {
          to {
              background-color: #fbf1c7;
              color: #df3f71;
          }
      }

      #battery.critical:not(.charging) {
          background-color: #282828;
          color: #d3869b;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      label:focus {
          background-color: #000000;
      }

      #backlight {
          color: #458588;
      }

      #temperature {
          color: #fabd2f;
      }

      #temperature.critical {
          background-color: #fbf1c7;
          color: #b57614;
      }

      #memory {
          color: #b8bb26;
      }

      #network {
          color: #fb4934;
      }

      #network.disconnected {
          background-color: #fbf1c7;
          color: #9d0006;
      }

      /*#disk {
          background-color: #964B00;
      }*/

      #pulseaudio {
          color: #fe8019;
      }

      #custom-mail {
          color: #458588;
          /*margin-top: 4px;*/
          margin-bottom: 0px;
      }
      #custom-unread-mail {
          color: #458588;
      }

      #pulseaudio.muted {
          background-color: #fbf1c7;
          color: #af3a03;
      }

      #tray {
      }

      #tray > .needs-attention {
          background-color: #fbf1c7;
          color: #3c3836;
      }

      #idle_inhibitor {
          background-color: #282828;
          color: #ebdbb2;
      }

      #idle_inhibitor.activated {
          background-color: #fbf1c7;
          color: #3c3836;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }

      #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state {
          background: #97e1ad;
          color: #000000;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state > label {
          padding: 0 5px;
      }

      #keyboard-state > label.locked {
          background: rgba(0, 0, 0, 0.2);
      }
    '';
    # systemd = {
    #   enable = true;
    #   target = "graphical-session.target";
    # };
  };
  systemd.user.services.waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
      ExecStart = "${config.programs.waybar.package}/bin/waybar";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}

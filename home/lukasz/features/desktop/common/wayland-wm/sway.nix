{ lib, pkgs, config, ... }:
let
  wofi = "${pkgs.wofi}/bin/wofi";
  kitty = "${config.programs.kitty.package}/bin/kitty";
  inherit (config.colorscheme) colors;
  modifier = "Mod4";
  terminal = kitty;
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;
    config = {
      inherit modifier terminal;
      menu = "${wofi} -S run";

      gaps = {
        smartBorders = "on";
        smartGaps = true;
        outer = 2;
        inner = 2;
      };
      keybindings = lib.mkOptionDefault {
        # Focus parent or child
        "${modifier}+bracketleft" = "focus parent";
        "${modifier}+bracketright" = "focus child";
      };

      colors = {
        focused = {
          border = "${colors.base0C}";
          background = "${colors.base00}";
          text = "${colors.base05}";
          indicator = "${colors.base09}";
          childBorder = "${colors.base0C}";
        };
        focusedInactive = {
          border = "${colors.base03}";
          background = "${colors.base00}";
          text = "${colors.base04}";
          indicator = "${colors.base03}";
          childBorder = "${colors.base03}";
        };
        unfocused = {
          border = "${colors.base02}";
          background = "${colors.base00}";
          text = "${colors.base03}";
          indicator = "${colors.base02}";
          childBorder = "${colors.base02}";
        };
        urgent = {
          border = "${colors.base09}";
          background = "${colors.base00}";
          text = "${colors.base03}";
          indicator = "${colors.base09}";
          childBorder = "${colors.base09}";
        };
      };
    };
    extraConfig = ''
      exec dbus-update-activation-environment WAYLAND_DISPLAY
      exec systemctl --user import-environment WAYLAND_DISPLAY
    '';
  };
}

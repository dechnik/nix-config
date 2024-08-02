{
  lib,
  pkgs,
  config,
  ...
}:
let
  wofi = "${pkgs.wofi}/bin/wofi";
  kitty = "${config.programs.kitty.package}/bin/kitty";
  inherit (config.colorscheme) palette;
  modifier = "Mod1";
  terminal = kitty;
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
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
        "${modifier}+Return" = "exec ${terminal}";
      };
      # bars = [ ];

      colors = {
        focused = {
          border = "${palette.base0C}";
          background = "${palette.base00}";
          text = "${palette.base05}";
          indicator = "${palette.base09}";
          childBorder = "${palette.base0C}";
        };
        focusedInactive = {
          border = "${palette.base03}";
          background = "${palette.base00}";
          text = "${palette.base04}";
          indicator = "${palette.base03}";
          childBorder = "${palette.base03}";
        };
        unfocused = {
          border = "${palette.base02}";
          background = "${palette.base00}";
          text = "${palette.base03}";
          indicator = "${palette.base02}";
          childBorder = "${palette.base02}";
        };
        urgent = {
          border = "${palette.base09}";
          background = "${palette.base00}";
          text = "${palette.base03}";
          indicator = "${palette.base09}";
          childBorder = "${palette.base09}";
        };
      };
    };
    extraConfig = ''
      exec dbus-update-activation-environment WAYLAND_DISPLAY
      exec systemctl --user import-environment WAYLAND_DISPLAY
    '';
  };
}

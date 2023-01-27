{
  colors,
  default,
  config,
  pkgs,
  ...
}:
# terminals
let
  inherit (config.colorscheme) colors;
in {
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      window = {
        decorations = "none";
        dynamic_padding = true;
        padding = {
          x = 5;
          y = 5;
        };
        startup_mode = "Maximized";
      };

      scrolling.history = 10000;

      font = {
        normal.family = config.fontProfiles.monospace.family;
        bold.family = config.fontProfiles.monospace.family;
        italic.family = config.fontProfiles.monospace.family;
        size = 10;
      };

      draw_bold_text_with_bright_colors = true;
      colors = rec {
        primary = {
          background = "#${colors.base00}";
          foreground = "#${colors.base05}";
        };
        normal = {
          black = "#${colors.base02}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0E}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base05}";
        };
        bright =
          normal
          // {
            black = "#${colors.base03}";
            white = "#${colors.base06}";
          };
      };
    };
  };
}

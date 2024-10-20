{
  colors,
  default,
  config,
  pkgs,
  ...
}:
# terminals
let
  inherit (config.colorscheme) palette;
in
{
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };
  # Set as default terminal
  xdg.mimeApps = {
    associations.added = {
      "x-scheme-handler/terminal" = "Alacritty.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/terminal" = "Alacritty.desktop";
    };
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
        normal.family = config.fontProfiles.monospace.name;
        bold.family = config.fontProfiles.monospace.name;
        italic.family = config.fontProfiles.monospace.name;
        size = config.fontProfiles.monospace.size;
      };

      colors = rec {
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = "#${palette.base00}";
          foreground = "#${palette.base05}";
        };
        normal = {
          black = "#${palette.base02}";
          red = "#${palette.base08}";
          green = "#${palette.base0B}";
          yellow = "#${palette.base0A}";
          blue = "#${palette.base0D}";
          magenta = "#${palette.base0E}";
          cyan = "#${palette.base0C}";
          white = "#${palette.base05}";
        };
        bright = normal // {
          black = "#${palette.base03}";
          white = "#${palette.base06}";
        };
      };
    };
  };
}

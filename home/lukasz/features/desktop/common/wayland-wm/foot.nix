{ pkgs, config, ... }:
let inherit (config.colorscheme) palette variant;
in {
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        pad = "12x12";
        term = "xterm-256color";

        font = "${config.fontProfiles.monospace.family}:size=10";

        include = "${pkgs.foot.themes}/share/foot/themes/gruvbox-dark";

        dpi-aware = "yes";
      };

      colors = {
        alpha = "0.9";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}

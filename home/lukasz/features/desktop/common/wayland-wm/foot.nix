{ config, ... }:
let inherit (config.colorscheme) colors kind;
in {
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        font = "${config.fontProfiles.monospace.family}:size=10";

        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}

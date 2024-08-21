{
  pkgs,
  lib,
  outputs,
  ...
}:
let
  browser = [ "brave.desktop" ];
  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
  };
in
{
  imports = [
    # ./firefox.nix
    ./chromium.nix
    ./font.nix
    ./mpv.nix
    ./gtk.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./qt.nix
    ./virt.nix
  ];
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  # services.gnome-keyring = {
  #   enable = true;
  #   components = [ "secrets" ];
  # };
  home.persistence = {
    # "/persist/home/lukasz".directories = [ ".local/share/keyrings" ];
  };

  home = {
    sessionVariables = {
      BROWSER = "brave";
    };
  };
  programs.browserpass.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;
  # xdg.mimeApps.defaultApplications = {
  #   "text/html" = browser;
  #   "text/xml" = browser;
  #   "x-scheme-handler/http" = browser;
  #   "x-scheme-handler/https" = browser;
  #   "applications/x-www-browser" = browser;
  # };
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
    lyrics
    deluge
    brave
    google-chrome
    obsidian
    ladybird
    # (vivaldi.override {
    #   proprietaryCodecs = true;
    #   enableWidevine = false;
    # })
    # tor-browser-bundle-bin
    pcmanfm
    meld
  ];
}

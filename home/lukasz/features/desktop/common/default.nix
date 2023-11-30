{ pkgs, lib, outputs, ... }:
let
  browser = [ "brave.desktop" ];
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
  xdg.mimeApps.defaultApplications = {
    "text/html" = browser;
    "text/xml" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "applications/x-www-browser" = browser;
  };
  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
    lyrics
    deluge
    brave
    obsidian
    tor-browser-bundle-bin
    pcmanfm
    meld
  ];
}

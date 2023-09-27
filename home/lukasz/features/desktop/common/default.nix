{ pkgs, lib, outputs, ... }:
{
  imports = [
    ./firefox.nix
    ./chromium.nix
    ./font.nix
    ./mpv.nix
    ./gtk.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./qt.nix
    ./virt.nix
  ];
  # services.gnome-keyring = {
  #   enable = true;
  #   components = [ "secrets" ];
  # };
  home.persistence = {
    # "/persist/home/lukasz".directories = [ ".local/share/keyrings" ];
  };

  home = {
    sessionVariables = {
      BROWSER = "firefox";
    };
  };
  programs.browserpass.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "applications/x-www-browser" = [ "firefox.desktop" ];
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

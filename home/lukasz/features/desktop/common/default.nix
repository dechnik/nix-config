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
      BROWSER = "brave";
    };
  };
  programs.browserpass.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "brave.desktop" ];
    "text/xml" = [ "brave.desktop" ];
    "x-scheme-handler/http" = [ "brave.desktop" ];
    "x-scheme-handler/https" = [ "brave.desktop" ];
  };
  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
    lyrics
    brave
    tor-browser-bundle-bin
    pcmanfm
    meld
    gtk-pipe-viewer
  ];
}

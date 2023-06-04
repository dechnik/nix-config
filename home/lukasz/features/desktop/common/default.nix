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
  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
    lyrics
    brave
    pcmanfm
    meld
    gtk-pipe-viewer
  ];
}

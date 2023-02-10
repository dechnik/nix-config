{ pkgs, lib, outputs, ... }:
{
  imports = [
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./qt.nix
    ./virt.nix
  ];
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };
  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
    lyrics
    meld
  ];
}

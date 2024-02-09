{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    # gsconnect
    # ideapad-mode
    vitals
    pkgs.gnome.gnome-tweaks
  ];
  services = {
    xserver = {
      desktopManager.gnome = {
        enable = true;
      };
    };
    gnome.games.enable = false;
  };
  # Fix broken stuff
  services.avahi.enable = false;
  networking.networkmanager.enable = false;
}

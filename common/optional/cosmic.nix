{ pkgs, lib, inputs, ... }:
{
  services.displayManager.sddm.enable = lib.mkForce false;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };
  # environment.etc."cosmic-comp/config.ron".source = lib.mkForce cosmic-config;
  # environment.systemPackages = [
  #   inputs.applet-gpg.packages.${pkgs.system}.default
  # ];
}

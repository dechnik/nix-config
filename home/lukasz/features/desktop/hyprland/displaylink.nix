{ inputs, pkgs, ... }:
let
  hyprland-displaylink = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
     wlroots = inputs.hyprland.packages.x86_64-linux.wlroots-hyprland.overrideAttrs (_: {
       patches = [../../../../../pkgs/patches/displaylink.patch];
     });
  };
in
{
  wayland.windowManager.hyprland = {
    package = hyprland-displaylink;
  };
}

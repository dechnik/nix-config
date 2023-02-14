{ inputs, pkgs, ... }:
let
  hyprland-nvidia = inputs.hyprland.packages.${pkgs.system}.hyprland-nvidia;
in
{
  wayland.windowManager.hyprland = {
    package = hyprland-nvidia;
  };
}

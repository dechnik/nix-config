{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ../common/wayland-wm
    inputs.hyprland.homeManagerModules.default
    ./tty-init.nix
  ];

  home.packages = with pkgs; [
    inputs.hyprwm-contrib.packages.${system}.grimblast
    swaybg
    swayidle
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig =
      (import ./monitors.nix {
        inherit lib;
        inherit (config) monitors;
      })
      + (import ./config.nix { inherit (config) colorscheme wallpaper; });
  };
}

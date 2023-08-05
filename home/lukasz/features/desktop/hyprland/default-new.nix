{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    ../common
    ../common/wayland-wm
    ./tty-init.nix
    ./basic-binds.nix
    ./systemd-fixes.nix
  ];

  home.packages = with pkgs; [
    inputs.hyprwm-contrib.grimblast
    swaybg
    swayidle
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
    };
    extraConfig = ''
    '';
  };
}

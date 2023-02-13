{ inputs, lib, osConfig, config, pkgs, ... }:
let
  hyprland-pkg = if osConfig.hardware.nvidia.modesetting.enable then inputs.hyprland.packages.${pkgs.system}.hyprland-nvidia
      else inputs.hyprland.packages.${pkgs.system}.default;
  hyprland-displaylink = hyprland-pkg.override {
     wlroots = inputs.hyprland.packages.x86_64-linux.wlroots-hyprland.overrideAttrs (_: {
       patches = [../../../../../pkgs/patches/displaylink.patch];
     });
  };
in {
  imports = [
    ../common
    ../common/wayland-wm
    inputs.hyprland.homeManagerModules.default
  ];

  programs = {
    fish.loginShellInit = ''
      if test (tty) = "/dev/tty1"
        exec Hyprland &> /dev/null
      end
    '';
    zsh.loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland &> /dev/null
      fi
    '';
    zsh.profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland &> /dev/null
      fi
    '';
  };

  home.packages = with pkgs; [
    inputs.hyprwm-contrib.packages.${system}.grimblast
    swaybg
    swayidle
  ];

  programs.waybar.package = pkgs.waybar.overrideAttrs (oa: {
    mesonFlags = (oa.mesonFlags or  [ ]) ++ [ "-Dexperimental=true" ];
  });

  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.default;
    package = hyprland-displaylink;
    extraConfig =
      (import ./monitors.nix {
        inherit lib;
        inherit (config) monitors;
      }) +
      (import ./config.nix {
        inherit (config) colorscheme wallpaper;
      });
  };
}

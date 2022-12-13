{ inputs, lib, pkgs, ... }:

{
  imports =
    [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-pc-ssd

      ./hardware-configuration.nix

      ../common/global
      ../common/users/lukasz.nix

      ../common/optional/pipewire.nix
    ];

  networking = {
    hostName = "dziad"; # Define your hostname.
    useDHCP = true;
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  programs = {
    dconf.enable = true;
  };

  services.dbus.packages = [ pkgs.gcr ];

  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];

  xdg.portal = {
    enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ vaapiVdpau ];
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

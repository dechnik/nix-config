{ inputs, lib, pkgs, ... }:

{
  imports =
    [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-pc-ssd

      ./hardware-configuration.nix
      # ./boot-loader.nix

      ../common/global
      ../common/users/lukasz

      ../common/optional/pipewire.nix
      ../common/optional/greetd.nix
      # ../common/optional/zfs.nix
      ../common/optional/quietboot.nix
    ];

  networking = {
    hostName = "dziad"; # Define your hostname.
    useDHCP = true;
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  programs = {
    dconf.enable = true;
  };

  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];

  services.dbus.packages = [ pkgs.gcr ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  hardware.nvidia.modesetting.enable = true;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

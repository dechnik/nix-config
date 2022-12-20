{ inputs, lib, pkgs, ... }:

{
  imports =
    [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-pc-ssd

      ./hardware-configuration.nix

      ../common/global
      ../common/users/lukasz

      ../common/optional/pipewire.nix
      ../common/optional/greetd.nix
      ../common/optional/quietboot.nix
    ];

  networking = {
    hostName = "dziad"; # Define your hostname.
    useDHCP = true;
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
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

  environment.systemPackages = [
    pkgs.nvidia-vaapi-driver
  ];

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

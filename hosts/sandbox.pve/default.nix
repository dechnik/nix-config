{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../common/optional/qemu-vm.nix
      ../../common/optional/nix-gc.nix
      ../../common/global
      ../../common/users/lukasz
    ];
  services.spice-vdagentd.enable = true;
  boot = {
    loader.grub = {
      enable = true;
      devices = [ "/dev/vda" ];
    };
    # loader = {
    #   systemd-boot = {
    #     enable = true;
    #     configurationLimit = 10;
    #   };
    #   efi = {
    #     canTouchEfiVariables = true;
    #     efiSysMountPoint = "/boot";
    #   };
    # };
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };

  networking = {
    hostName = "sandbox"; # Define your hostname.
    domain = "pve.dechnik.net";
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces."ens18" = {
      useDHCP = true;
    };
  };
  system.stateVersion = "23.11"; # Did you read the comment?
}

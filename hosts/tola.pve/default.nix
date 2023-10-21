{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../common/optional/qemu-vm.nix
      ../../common/optional/nix-gc.nix
      ../../common/global
      ../../common/users/lukasz
      inputs.disko.nixosModules.disko
    ];
  services.spice-vdagentd.enable = true;
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  networking = {
    hostName = "tola"; # Define your hostname.
    domain = "pve.dechnik.net";
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces."ens18" = {
      useDHCP = true;
    };
  };
  system.stateVersion = "23.11"; # Did you read the comment?
}

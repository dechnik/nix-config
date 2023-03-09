{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      ../../common/optional/btrfs-optin-persistence.nix
      ../../common/optional/encrypted-root.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "ahci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "kvm-intel" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  fileSystems."/old" = {
    device = "/dev/disk/by-uuid/ca2956e1-474e-4238-92d5-39c26f8c5205";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D065-07C9";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8192;
  }];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}

{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      ../common/optional/btrfs-optin-persistence.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      # kernelModules = [ "kvm-amd" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/be1c825f-1e04-4e02-a4d9-bf6676806b76";
    fsType = "ext4";
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/GAMES";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/A2C4-DBDC";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}

{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      ../common/optional/btrfs-optin-persistence.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "kvm-amd" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/a6ce31dc-4c87-4950-970a-9a1d3a0b5968";
    fsType = "btrfs";
    options = ["noatime"];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/A2C4-DBDC";
      fsType = "vfat";
    };
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}

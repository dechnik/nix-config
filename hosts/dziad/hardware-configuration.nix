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

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/dziad";
      fsType = "btrfs";
      options = [ "subvol=boot" ];
    };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}

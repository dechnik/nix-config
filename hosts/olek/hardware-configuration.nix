{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      ../common/optional/btrfs-optin-persistence.nix
      ../common/optional/encrypted-root.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_scsi" "sd_mod" ];
    };
    kernelModules = [ "kvm-intel" ];
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
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8196;
  }];


  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform.system = "x86_64-linux";
}

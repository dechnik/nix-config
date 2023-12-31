{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      # ../../common/optional/ephemeral-btrfs.nix
      ../../common/optional/tmpfs-root.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_scsi" "sd_mod" ];
    };
    kernelModules = [ "kvm-intel" ];
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
      };
    };
  };

  fileSystems."/boot" =
    {
      device = "/dev/vda1";
      fsType = "btrfs";
      options = [ "subvol=boot" ];
    };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8196;
  }];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform.system = "x86_64-linux";
}

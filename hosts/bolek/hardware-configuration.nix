{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
      ../common/optional/btrfs-optin-persistence.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
    };
    kernelModules = [ "kvm-intel" ];
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/vda";
      };
    };
  };

  fileSystems."/boot" =
    { device = "/dev/vda1";
      fsType = "btrfs";
      options = [ "subvol=boot" ];
    };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform.system = "x86_64-linux";
}
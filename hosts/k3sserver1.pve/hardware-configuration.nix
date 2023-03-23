{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
    kernelModules = [ "kvm-intel" ];

    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/vda";
      };
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/k3sserver1";
      fsType = "ext4";
    };
  boot.cleanTmpDir = true;

  swapDevices = [{
    device = "/swap/swapfile";
    size = 2048;
  }];


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

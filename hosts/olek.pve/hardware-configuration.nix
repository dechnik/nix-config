{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./disks.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_scsi" "sd_mod" ];
    };
    kernelModules = [ "kvm-intel" ];
    loader = {
      grub = {
        # no need to set devices, disko will add all devices that have a EF02 partition to the list already
        # devices = [ ];
        efiSupport = true;
        zfsSupport = true;
        efiInstallAsRemovable = true;
      };
    };
    zfs.devNodes = "/dev/disk/by-path";
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };

  networking.hostId = "92e65e5c";

  fileSystems."/persist" =
    { device = "zroot/root/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/" =
    { device = "zroot/root";
      fsType = "zfs";
      neededForBoot = true;
    };

  # fileSystems."/" =
  #   { device = "zroot/root";
  #     fsType = "zfs";
  #   };

  # fileSystems."/nix" =
  #   { device = "zroot/root/nix";
  #     fsType = "zfs";
  #   };

  # fileSystems."/home" =
  #   { device = "zroot/root/home";
  #     fsType = "zfs";
  #   };

  # fileSystems."/boot" =
  #   {
  #     device = "/dev/disk/by-uuid/EEF2-3692";
  #     fsType = "vfat";
  #   };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform.system = "x86_64-linux";
}

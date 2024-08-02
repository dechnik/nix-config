{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    supportedFilesystems = [ "zfs" ];
    # Since I'm using nixos-unstable mostly, the latest ZFS is sometimes
    # incompatible with the latest kernel.
    zfs.enableUnstable = true;
  };
  services.zfs.autoScrub.enable = true;

  networking.hostId = lib.mkForce "aa67143f";
  disko.devices = import ./disks.nix { };

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      # kernelModules = [ "kvm-amd" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 20;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };
  boot.kernelParams = [ "nohibernate" ];

  disko.devices = import ./disks.nix { };

  # fileSystems = {
  #   "/old" = {
  #     device = "/dev/disk/by-label/dziad";
  #     fsType = "btrfs";
  #     options = [ "subvol=root" "compress=zstd" ];
  #   };

  #   "/old/persist" = {
  #     device = "/dev/disk/by-label/dziad";
  #     fsType = "btrfs";
  #     options = [ "subvol=persist" "compress=zstd" ];
  #   };

  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/be1c825f-1e04-4e02-a4d9-bf6676806b76";
  #   fsType = "ext4";
  # };

  environment.systemPackages = with pkgs; [ mdadm ];
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  # fileSystems."/boot/efi" = {
  #   device = "/dev/disk/by-uuid/A2C4-DBDC";
  #   fsType = "vfat";
  # };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}

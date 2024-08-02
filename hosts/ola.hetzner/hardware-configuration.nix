{ modulesPath, ... }:
{
  imports = [
    ../../common/optional/btrfs-optin-persistence.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sd_mod"
        "sr_mod"
      ];
    };
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
      };
    };
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    options = [ "subvol=boot" ];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 2048;
    }
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}

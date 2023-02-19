{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../common/optional/qemu-vm.nix
      # ../common/optional/syncthing.nix
      ../common/global
      ../common/users/lukasz
    ];

  networking = {
    hostName = "bolek"; # Define your hostname.
    useDHCP = true;
    extraHosts = ''
      127.0.0.1 cache.dechnik.net
    '';
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  system.stateVersion = "22.05"; # Did you read the comment?
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;
  # Increase swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

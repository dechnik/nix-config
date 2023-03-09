{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../../common/optional/qemu-vm.nix
      ../../common/optional/postfix.nix
      ../../common/global
      ../../common/users/lukasz
    ];

  networking = {
    hostName = "lolek"; # Define your hostname.
    domain = "pve.dechnik.net";
    useDHCP = true;
    extraHosts = ''
      10.30.10.12 cache.dechnik.net
      10.30.10.12 tailscale.dechnik.net
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

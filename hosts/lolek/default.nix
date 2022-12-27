{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      # ./services

      ../common/global
      ../common/users/lukasz
    ];

  networking = {
    hostName = "lolek"; # Define your hostname.
    useDHCP = true;
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

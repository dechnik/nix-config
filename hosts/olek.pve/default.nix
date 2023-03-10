{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../common/optional/qemu-vm.nix
      # ../common/optional/greetd.nix
      ../../common/optional/xserver.nix
      ../../common/optional/gnome.nix
      ../../common/optional/postfix.nix
      ../../common/global
      ../../common/users/lukasz
      ./services
    ];

  networking = {
    hostName = "olek"; # Define your hostname.
    domain = "pve.dechnik.net";
    useDHCP = true;
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  programs = {
    dconf.enable = true;
  };

  services.dbus.packages = [ pkgs.gcr ];

  system.stateVersion = "22.05"; # Did you read the comment?
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
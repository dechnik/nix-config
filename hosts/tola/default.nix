{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../common/optional/qemu-vm.nix
      ../common/optional/gnome.nix
      ../common/global
      ../common/users/lukasz
    ];

  networking = {
    hostName = "tola"; # Define your hostname.
    useDHCP = true;
    extraHosts = ''
      10.30.10.12 cache.dechnik.net
      10.30.10.12 tailscale.dechnik.net
    '';
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

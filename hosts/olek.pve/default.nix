{ inputs, config, lib, ... }:

{
  imports =
    [
      inputs.nixos-cosmic.nixosModules.default
      ./hardware-configuration.nix

      ../../common/optional/auto-upgrade.nix
      ../../common/optional/qemu-vm.nix
      # ../common/optional/greetd.nix
      # ../../common/optional/xserver.nix
      # ../../common/optional/gnome.nix
      # ../../common/optional/plasma6.nix
      ../../common/optional/nix-gc.nix
      ../../common/global
      ../../common/users/lukasz
      ./services
      inputs.disko.nixosModules.disko
    ];

    # Cosmic Test
  services.xserver.displayManager.sddm.enable = lib.mkForce false;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  services.spice-vdagentd.enable = true;

  my.lan = "ens19";

  networking = {
    hostName = "olek"; # Define your hostname.
    domain = "pve.dechnik.net";
    # useDHCP = lib.mkDefault true;
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces."ens18" = {
      useDHCP = true;
    };
    interfaces."${config.my.lan}" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.60.0.4";
          prefixLength = 24;
        }
      ];
      ipv4.routes = [
        {
          address = "10.60.0.1";
          prefixLength = 32;
        }
      ];
    };
  };

  programs = {
    dconf.enable = true;
  };

  system.stateVersion = "22.05"; # Did you read the comment?
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

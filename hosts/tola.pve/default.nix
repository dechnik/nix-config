{ config, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../common/optional/auto-upgrade.nix
      ../../common/optional/qemu-vm.nix
      # ../../common/optional/greetd.nix
      ../../common/optional/vpn.nix
      ../../common/optional/xserver.nix
      ../../common/optional/gnome.nix
      ../../common/optional/nix-gc.nix
      ../../common/global
      ../../common/users/lukasz
      ./services
    ];

  services.spice-vdagentd.enable = true;

  my.lan = "ens19";

  networking = {
    hostName = "tola"; # Define your hostname.
    domain = "pve.dechnik.net";
    nameservers = [
      "10.60.0.1"
    ];
    defaultGateway = "10.60.0.1";
    defaultGateway6 = "";
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces."ens18" = {
      useDHCP = true;
    };
    interfaces."${config.my.lan}" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.60.0.3";
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

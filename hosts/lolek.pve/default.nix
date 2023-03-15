{ lib, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../../common/optional/qemu-vm.nix
      ../../common/optional/postfix.nix
      ../../common/global
      ../../common/global/network.nix
      ../../common/users/lukasz
    ];

  my.lan = "ens19";

  networking = {
    hostName = "lolek";
    domain = "pve.dechnik.net";
    nameservers = [
      "10.60.0.1"
    ];
    defaultGateway = "10.60.0.1";
    defaultGateway6 = "";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces."ens18" = {
      useDHCP = true;
    };
    interfaces."${config.my.lan}" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.60.0.2";
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

  system.stateVersion = "22.05"; # Did you read the comment?
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;
  # Increase swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

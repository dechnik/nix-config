{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../../common/optional/qemu-vm.nix
      ../../common/optional/syncthing.nix
      ../../common/optional/postfix.nix
      ../../common/global
      ../../common/global/network.nix
      ../../common/users/lukasz
    ];

  sops.secrets = {
    syncthing-cert = {
      sopsFile = ./secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/syncthing-cert.pem";
    };
    syncthing-key = {
      sopsFile = ./secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/syncthing-key.pem";
    };
  };

  my.wan = "ens19";
  my.lan = "lan0";

  networking = {
    hostName = "bolek"; # Define your hostname.
    domain = "pve.dechnik.net";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    bridges = {
      lan0.interfaces = [ ];
    };

    interfaces = {
      ens18 = {
        useDHCP = true;
      };

      ${config.my.wan} = {
        useDHCP = true;
        # ipv4.addresses = [
        #   {
        #     address = "185.243.216.95";
        #     prefixLength = 24;
        #   }
        # ];
        # ipv6.addresses = [
        #   {
        #     address = "2a03:94e0:ffff:185:243:216::95";
        #     prefixLength = 118;
        #   }
        # ];

        tempAddress = "disabled";
      };

      ${config.my.lan} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.60.0.1";
            prefixLength = 24;
          }
        ];
        tempAddress = "disabled";
      };
    };
    # useDHCP = true;
    extraHosts = ''
      127.0.0.1 cache.dechnik.net
      127.0.0.1 tailscale.dechnik.net
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

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../../common/optional/qemu-vm.nix
      ../../common/optional/consul-server.nix
      ../../common/optional/syncthing.nix
      ../../common/optional/postfix.nix
      ../../common/optional/nginx.nix
      ../../common/optional/coredns.nix
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
    defaultGateway = "195.22.99.254";
    bridges = {
      lan0.interfaces = [ ];
    };

    interfaces = {
      ens18 = {
        useDHCP = true;
        tempAddress = "disabled";
      };

      ${config.my.wan} = {
        ipv4.addresses = [
          {
            address = "195.22.99.45";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fe80::8cd9:35ff:fe05:bbdd";
            prefixLength = 64;
          }
        ];

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

{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../../common/optional/qemu-vm.nix
      ../../common/optional/nix-gc2.nix
      ../../common/optional/consul.nix
      ../../common/optional/docker.nix
      ../../common/optional/promtail.nix
      ../../common/optional/node-exporter.nix
      ../../common/optional/systemd-exporter.nix
      ../../common/global
      ../../common/users/lukasz
      inputs.disko.nixosModules.disko
    ];
  services.spice-vdagentd.enable = true;
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

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
  system.stateVersion = "23.11"; # Did you read the comment?
  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
  };
}

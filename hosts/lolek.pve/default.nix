{ lib, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services

      ../../common/optional/qemu-vm.nix
      ../../common/optional/consul.nix
      ../../common/optional/promtail.nix
      ../../common/optional/avahi.nix
      ../../common/optional/node-exporter.nix
      ../../common/optional/systemd-exporter.nix
      ../../common/optional/postfix.nix
      ../../common/global
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
    firewall = {
      enable = lib.mkForce true;
      # This is a special override for gateway machines as we
      # dont want to use "openFirewall" here since it makes
      # everything world available.
      allowedTCPPorts = lib.mkForce [
        22
        80 # HTTP
      ];

      allowedUDPPorts = lib.mkForce [
        config.services.tailscale.port
      ];

      trustedInterfaces = [ config.my.lan ];
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = true;
  # Increase swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

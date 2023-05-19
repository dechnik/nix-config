{ config, inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    ./hardware-configuration.nix

    ./services
    ../../common/global
    ../../common/optional/postgres.nix
    ../../common/optional/consul-server.nix
    ../../common/optional/promtail.nix
    ../../common/optional/node-exporter.nix
    ../../common/optional/systemd-exporter.nix
    ../../common/users/lukasz
  ];

  my.wan = "enp1s0";
  my.lan = "enp7s0";

  networking = {
    hostName = "ola";
    domain = "hetzner.dechnik.net";

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    interfaces = {
      "${config.my.wan}" = {
        useDHCP = true;
      };

      ${config.my.lan} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.62.0.1";
            prefixLength = 24;
          }
        ];
        tempAddress = "disabled";
      };
    };
    firewall = {
      enable = lib.mkForce true;
      # This is a special override for gateway machines as we
      # dont want to use "openFirewall" here since it makes
      # everything world available.
      allowedTCPPorts = lib.mkForce [
        22 # SSH
        25 # SSH
        80 # HTTP
        443 # HTTPS
        143 # imap
        993 # imap
        587 # smtp
        465 # smtp
      ];

      allowedUDPPorts = lib.mkForce [
        443 # HTTPS
        config.services.tailscale.port
        config.networking.wireguard.interfaces.wg0.listenPort
      ];

      trustedInterfaces = [ config.my.lan ];
    };
  };
  system.stateVersion = "22.05";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

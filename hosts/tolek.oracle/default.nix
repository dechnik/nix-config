{ lib, config, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./services
    ../../common/global
    ../../common/users/lukasz
    ../../common/optional/qemu-vm.nix
    ../../common/optional/postfix.nix
    ../../common/optional/nginx.nix
    ../../common/optional/consul-server.nix
    ../../common/optional/promtail.nix
    ../../common/optional/node-exporter.nix
    ../../common/optional/systemd-exporter.nix
  ];

  my.wan = "enp0s3";
  my.lan = "enp1s0";
  disabledModules = [ "services/databases/lldap.nix" ];

  networking = {
    hostName = "tolek";
    domain = "oracle.dechnik.net";

    defaultGateway = "10.0.0.1";

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
            address = "10.61.0.1";
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
        80 # HTTP
        443 # HTTPS
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

  boot.binfmt.emulatedSystems = [ "x86_64-linux" "i686-linux" ];
}

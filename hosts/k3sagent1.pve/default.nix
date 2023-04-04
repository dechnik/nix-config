{ lib, config, pkgs, ... }: let
  network = import ../../common/functions/network.nix {inherit lib pkgs;};
  s = import ../../metadata/sites.nix {inherit lib config;};
in {
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
      ../../common/global
      ../../common/users/lukasz
    ];

  my.lan = "ens18";

  networking =
    network.base
    {
      hostName = "k3sagent1";
      interface = config.my.lan;
      ipv4 = "10.60.0.121";
      site = s.sites.pve;
    };

  system.stateVersion = "22.05"; # Did you read the comment?
}

{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    ./hardware-configuration.nix

    ./services
    ../../common/global
    ../../common/optional/nginx.nix
    ../../common/optional/consul.nix
    ../../common/users/lukasz
  ];

  networking = {
    hostName = "ola";
    domain = "hetzner.dechnik.net";
    useDHCP = true;
  };
  system.stateVersion = "22.05";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

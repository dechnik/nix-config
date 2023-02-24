{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    ./hardware-configuration.nix

    # ./services
    ../common/global
    ../common/users/lukasz
  ];

  networking = {
    hostName = "ola";
    useDHCP = true;
  };
  system.stateVersion = "22.05";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot.binfmt.emulatedSystems = [ "x86_64-linux" "i686-linux" ];
}

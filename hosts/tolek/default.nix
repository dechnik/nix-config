{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/lukasz
    ../common/optional/qemu-vm.nix
  ];

  networking = {
    hostName = "tolek";
    useDHCP = true;
  };
  system.stateVersion = "22.05";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot.binfmt.emulatedSystems = [ "x86_64-linux" "i686-linux" ];
}

{
  imports = [
    ./hardware-configuration.nix

    # ./services
    ../common/global
    ../common/users/lukasz
    ../common/optional/qemu-vm.nix
    ../common/optional/postfix.nix
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

{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      inputs.hardware.nixosModules.common-cpu-amd
      # inputs.hardware.nixosModules.common-gpu-nvidia
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.nixos-cosmic.nixosModules.default
      ./hardware-configuration.nix
      inputs.disko.nixosModules.disko
      ./services

      # ./boot-loader.nix

      ../../common/global
      ../../common/users/lukasz

      ../../common/optional/fping.nix
      ../../common/optional/docker.nix
      ../../common/optional/pipewire.nix
      # ../../common/optional/greetd.nix
      ../../common/optional/gaming.nix
      # ../../common/optional/qtile.nix
      ../../common/optional/vpn-nn.nix
      ../../common/optional/bluetooth.nix
      # ../../common/optional/pantalaimon.nix
      ../../common/optional/zram.nix
      ../../common/optional/nix-gc.nix
      ../../common/optional/cosmic.nix
      # ../common/optional/postfix.nix
      # ../../common/optional/gamemode.nix
      # ../common/optional/zfs.nix
      # ../common/optional/quietboot.nix
    ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  sops.secrets = {
    oauth2ms = {
      sopsFile = ../../common/secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/oauth2ms";
    };
    vdirsyncer-config = {
      sopsFile = ../../common/secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/vdir-config";
    };
  };

  my.wan = "eno1";
  services.gvfs.enable = true;

  services.dbus.packages = [
    pkgs.pcmanfm
  ];

  networking = {
    hostName = "dziad"; # Define your hostname.
    domain = "dechnik.net";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    #
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    usePredictableInterfaceNames = lib.mkForce true;
    defaultGateway = "10.10.10.1";

    interfaces = {
      ${config.my.wan} = {
        ipv4.addresses = [
          {
            address = "10.10.10.3";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fe80::1ac0:4dff:fe25:fcb6";
            prefixLength = 64;
          }
        ];

        tempAddress = "disabled";
      };
    };
  };

  boot = {
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    binfmt.emulatedSystems = [ "aarch64-linux" "i686-linux" ];
  };

  programs = {
    dconf.enable = true;
  };

  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;

  # hardware.nvidia = {
  #   prime.offload.enable = false;
  #   modesetting.enable = true;
  # };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}

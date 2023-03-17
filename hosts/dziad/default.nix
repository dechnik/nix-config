{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      ./services

      ./hardware-configuration.nix
      # ./boot-loader.nix

      ../../common/global
      ../../common/users/lukasz

      ../../common/optional/pipewire.nix
      ../../common/optional/greetd.nix
      ../../common/optional/vpn.nix
      ../../common/optional/bluetooth.nix
      ../../common/optional/syncthing.nix
      ../../common/global/network.nix
      # ../common/optional/postfix.nix
      ../../common/optional/gamemode.nix
      # ../common/optional/zfs.nix
      # ../common/optional/quietboot.nix
    ];

  sops.secrets = {
    syncthing-cert = {
      sopsFile = ./secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/syncthing-cert.pem";
    };
    syncthing-key = {
      sopsFile = ./secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/syncthing-key.pem";
    };
    oauth2ms = {
      sopsFile = ../../common/secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/oauth2ms";
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
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
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
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  programs = {
    dconf.enable = true;
  };

  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];

  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      inputs.xdph.packages.${pkgs.system}.default
    ];
    wlr.enable = false;
  };

  hardware.nvidia.modesetting.enable = true;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      # inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-gpu-intel
      inputs.hardware.nixosModules.common-pc-ssd

      ./hardware-configuration.nix

      ../../common/global
      ../../common/users/lukasz
      ./services

      ../../common/optional/docker.nix
      ../../common/optional/pipewire.nix
      ../../common/optional/greetd.nix
      ../../common/optional/wireless.nix
      ../../common/optional/bluetooth.nix
      ../../common/optional/syncthing.nix
      ../../common/optional/printing.nix
      ../../common/optional/vpn.nix
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

  services.gvfs.enable = true;

  services.dbus.packages = [
    pkgs.pcmanfm
  ];

  networking = {
    hostName = "ldlat"; # Define your hostname.
    domain = "dechnik.net";
    interfaces = {
      "enp43s0" = {
        useDHCP = true;
      };
      "wlp0s20f3" = {
        useDHCP = true;
      };
    };
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
    # kernelPackages = pkgs.linuxKernel.packages.linux_zen.extend (self: super: {
    #   evdi = super.evdi.overrideAttrs (o: rec {
    #     src = pkgs.fetchFromGitHub {
    #       owner = "DisplayLink";
    #       repo = "evdi";
    #       rev = "bdc258b25df4d00f222fde0e3c5003bf88ef17b5";
    #       sha256 = "mt+vEp9FFf7smmE2PzuH/3EYl7h89RBN1zTVvv2qJ/o=";
    #     };
    #   });
    # });
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  programs = {
    dconf.enable = true;
  };

  services.xserver.videoDrivers = [ "modesetting" "displaylink" ];

  services.thermald.enable = lib.mkDefault true;
  environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  # Enable fwupd
  services.fwupd.enable = lib.mkDefault true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      inputs.xdph.packages.${pkgs.system}.default
    ];
    wlr.enable = false;
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    cpu.intel.updateMicrocode = true;

    enableRedistributableFirmware = true;
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

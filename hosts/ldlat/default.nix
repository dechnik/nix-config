{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      # inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-gpu-intel
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.nixos-cosmic.nixosModules.default

      ./hardware-configuration.nix

      ../../common/global
      ../../common/users/lukasz
      ./services

      ../../common/optional/fping.nix
      ../../common/optional/docker.nix
      ../../common/optional/pipewire.nix
      # ../../common/optional/greetd.nix
      # ../../common/optional/qtile.nix
      ../../common/optional/wireless.nix
      ../../common/optional/bluetooth.nix
      ../../common/optional/printing.nix
      # ../../common/optional/pantalaimon.nix
      ../../common/optional/vpn.nix
      ../../common/optional/nix-gc.nix
    ];

  services.displayManager.sddm.enable = lib.mkForce false;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
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
    # kernelPackages = pkgs.linuxKernel.packages.linux_6_5;
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
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

  services.xserver.videoDrivers = [ "modesetting" ];

  services.thermald.enable = lib.mkDefault true;
  environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  # Enable fwupd
  services.fwupd.enable = lib.mkDefault true;

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

{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../../common/global
    ../../common/users/lukasz
    ./services

    ../../common/optional/fping.nix
    ../../common/optional/docker.nix
    ../../common/optional/pipewire.nix
    ../../common/optional/greetd.nix
    # ../../common/optional/qtile.nix
    # ../../common/optional/wireless-nn.nix
    ../../common/optional/wireless.nix
    ../../common/optional/bluetooth.nix
    ../../common/optional/printing.nix
    # ../../common/optional/pantalaimon.nix
    # ../../common/optional/vpn-nn.nix
    ../../common/optional/vpn.nix
    ../../common/optional/nix-gc.nix
    # ../../common/optional/cosmic.nix
  ];

  environment.systemPackages = [
    config.boot.kernelPackages.cpupower
    pkgs.boosteroid
  ];
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config = {
      common.default = "*";
    };
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
  services.zerotierone.enable = true;

  services.gvfs.enable = true;

  services.dbus.packages = [ pkgs.pcmanfm ];

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
    networkmanager.enable = lib.mkForce false; # Easiest to use and most distros use this by default.
    # networkmanager.unmanaged = [ "tailscale0" "lo" "wg0" ];
  };
  # networking.networkmanager.settings = {
  #   connectivity = {
  #     uri = "http://nmcheck.gnome.org/check_network_status.txt";
  #   };
  # };

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
  # Enable fwupd
  services.fwupd.enable = lib.mkDefault true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    cpu.intel.updateMicrocode = true;

    enableRedistributableFirmware = true;
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}

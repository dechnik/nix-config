let
  configuration =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with pkgs;
    let
      pinentryFlavour =
        if xserverCfg.desktopManager.lxqt.enable || xserverCfg.desktopManager.plasma5.enable then
          "qt"
        else if xserverCfg.desktopManager.xfce.enable then
          "gtk2"
        else if xserverCfg.enable || config.programs.sway.enable then
          "gnome3"
        else
          "curses";

    in
    {
      nixpkgs.config = {
        allowBroken = true;
      };

      isoImage.isoBaseName = lib.mkForce "nixos-ld";
      # Uncomment this to disable compression and speed up image creation time
      #isoImage.squashfsCompression = "gzip -Xcompression-level 1";

      boot.kernelPackages = linuxPackages_latest;
      # Always copytoram so that, if the image is booted from, e.g., a
      # USB stick, nothing is mistakenly written to persistent storage.
      boot.kernelParams = [ "copytoram" ];
      # Secure defaults
      boot.tmp.cleanOnBoot = true;

      services.pcscd.enable = true;

      nix = {
        settings = {
          substituters = [
            "https://cache.dechnik.net"
            "https://hyprland.cachix.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.dechnik.net:VM4JPWTGlfhOxnJsFk1r325lDewW44eyZ32ivqPaFJQ="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };

      programs = {
        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };

      environment.systemPackages = [
        # Tools for backing up keys
        parted
        cryptsetup
        git
      ];
    };

  nixos = import <nixpkgs/nixos/release.nix> {
    inherit configuration;
    supportedSystems = [ "x86_64-linux" ];
  };

  # Choose the one you like:
  nixos-ld = nixos.iso_minimal; # No graphical environment
  #nixos-yubikey = nixos.iso_gnome;
  #nixos-yubikey = nixos.iso_plasma5;

in
{
  inherit nixos-ld;
}

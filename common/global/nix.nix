{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      substituters = [
        "https://hyprland.cachix.org?priority=43"
        "https://nix-community.cachix.org?priority=41"
        "https://cosmic.cachix.org?priority=42"
        "https://attic.dechnik.net/system?priority=44"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        "system:5mtbpEmaoC7RVnZJz/KZU2Of2QXQTMBriCJjt3SK9Iw="
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
      system-features = [
        "kvm"
        "big-parallel"
      ];
    };
    # package = pkgs.nixUnstable;
    # package = pkgs.nixVersions.nix_2_12;
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 14d";
    # };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };
}

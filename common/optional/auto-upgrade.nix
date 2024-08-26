{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  toplevel = builtins.replaceStrings [ ".dechnik.net" ] [ "" ] config.networking.fqdn;
  hostname = builtins.replaceStrings [ "." ] [ "_" ] toplevel;
  upgrade_flake = "github:dechnik/nix-config/release-${hostname}#${toplevel}";
  check_flake = "github:dechnik/nix-config/release-${hostname}";
  # Only enable auto upgrade if current config came from a clean tree
  # This avoids accidental auto-upgrades when working locally.
  isClean = inputs.self ? rev;
in
{
  system.autoUpgrade = {
    enable = isClean;
    dates = "daily";
    flags = [
      "--refresh"
      "--accept-flake-config"
    ];
    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "05:00";
    };
    flake = upgrade_flake;
  };
  # Only run if current config (self) is older than the new one.
  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    serviceConfig.ExecCondition = lib.getExe (
      pkgs.writeShellScriptBin "check-date" ''
        lastModified() {
          nix flake metadata "$1" --refresh --json | ${lib.getExe pkgs.jq} '.lastModified'
        }
        test "$(lastModified "${check_flake}")"  -gt "$(lastModified "self")"
      ''
    );
  };
}

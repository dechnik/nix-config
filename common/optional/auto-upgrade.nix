{ config, inputs, ... }:
let
  toplevel = builtins.replaceStrings [".dechnik.net"] [""] config.networking.fqdn;
  hostname = builtins.replaceStrings ["."] ["_"] toplevel;
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
    ];
    flake = "git+https://git.dechnik.net/lukasz/nix-config.git?ref=release-${hostname}#${toplevel}";
  };
}

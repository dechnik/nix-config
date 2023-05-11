{ config, inputs, ... }:
let
  toplevel = builtins.replaceStrings [".dechnik.net"] [""] config.networking.fqdn;
  hostname = builtins.replaceStrings ["."] ["_"] toplevel;
in
{
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    flags = [
      "--refresh"
    ];
    flake = "git+https://git.dechnik.net/lukasz/nix-config.git?ref=release-${hostname}#${toplevel}";
  };
}

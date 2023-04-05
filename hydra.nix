{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) replaceStrings filterAttrs nameValuePair mapAttrs elem;

  notBroken = pkg: !(pkg.meta.broken or false);
  hasPlatform = sys: pkg: elem sys (pkg.meta.platforms or [ ]);
  filterValidPkgs = sys: pkgs: filterAttrs (_: pkg: hasPlatform sys pkg && notBroken pkg) pkgs;
  mangleName = replaceStrings [ "." ] [ "_" ];
  # getCfg = name: cfg: cfg.config.system.build.toplevel;
  getCfg = name: config: nameValuePair (mangleName name) config.config.system.build.toplevel;
in
{
  pkgs = mapAttrs filterValidPkgs outputs.packages;
  hosts = inputs.nixpkgs.lib.mapAttrs' getCfg outputs.nixosConfigurations;
}

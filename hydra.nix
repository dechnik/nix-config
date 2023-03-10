{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) filterAttrs mapAttrs elem;

  notBroken = pkg: !(pkg.meta.broken or false);
  hasPlatform = sys: pkg: elem sys pkg.meta.platforms;
  filterValidPkgs = sys: pkgs: filterAttrs (_: pkg: hasPlatform sys pkg && notBroken pkg) pkgs;
  getCfg = name: cfg: cfg.config.system.build.toplevel;
in
{
  pkgs = mapAttrs filterValidPkgs outputs.packages;
  hosts = mapAttrs getCfg outputs.nixosConfigurations;
}
#{ self, nixpkgs, flake-utils, ... }:
#(nixpkgs.lib.mapAttrs'
#  (name: config: nixpkgs.lib.nameValuePair name config.config.system.build.toplevel)
#  self.nixosConfigurations
#)
#    hydraJobs = lib.genAttrs hydraSystems (system: let
#      # Hydra doesn't allow job names containing periods.
#      mangleName = lib.replaceStrings [ "." ] [ "_" ];
#      mangleAttrName = name: lib.nameValuePair (mangleName name);
#    in lib.mapAttrs' mangleAttrName self.checks.${system});

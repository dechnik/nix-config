{ inputs, outputs }:
{
  meta = {
    machinesFile = ./hosts;
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
    };

    specialArgs = {
      inherit inputs;
    };
  };
}
// builtins.mapAttrs
  (name: value: {
    deployment.buildOnTarget =
      # TODO(kradalby): aarch64 linux machines get grumpy about some
      # delegation stuff
      if value.config.nixpkgs.system == "aarch64-linux"
      then true
      else false;
    # nixpkgs.system = value.config.nixpkgs.system;
    # imports = value._module.args.modules;
  })
  outputs.nixosConfigurations

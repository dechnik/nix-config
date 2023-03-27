{ inputs, outputs }:
{
  meta = {
    machinesFile = ./hosts;
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      # inherit overlays;
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
      ];
    };

    specialArgs = { inherit inputs outputs; };
    # specialArgs = {
    #   inherit inputs;
    # };
  };
}
// builtins.mapAttrs
  (name: value: {
    deployment = {
      buildOnTarget =
        # TODO(kradalby): aarch64 linux machines get grumpy about some
        # delegation stuff
        if value.config.nixpkgs.hostPlatform.system == "aarch64-linux"
        then true
        else false;
      allowLocalDeployment = true;
    };
    nixpkgs.system = value.config.nixpkgs.hostPlatform.system;
    imports = value._module.args.modules;
  })
  outputs.nixosConfigurations

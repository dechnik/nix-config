{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; })
    colorschemeFromPicture
    nixWallpaperFromScheme
    ;
in
{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.nix-colors.homeManagerModule
    ../features/cli
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "lukasz";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";

    persistence = {
      "/persist/home/lukasz" = {
        directories = [
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Videos"
          "Org"
          "Roam"
        ];
        allowOther = true;
      };
    };
  };
  colorscheme = lib.mkDefault colorSchemes.gruvbox-dark-hard;

  home.file.".colorscheme".text = config.colorscheme.slug;

}

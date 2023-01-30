{ pkgs, config, ... }:
let
  inherit (config) colorscheme;
in
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "${colorscheme.slug}";
      editor = {
        line-number = "absolute";
        indent-guides.render = true;
      };
    };
    themes = import ./theme.nix { inherit colorscheme; };
    # languages = with pkgs; [
    #   {
    #     name = "bash";
    #     language-server = {
    #       command = "${nodePackages.bash-language-server}/bin/bash-language-server";
    #       args = ["start"];
    #     };
    #     auto-format = true;
    #   }
    #   {
    #     name = "nix";
    #     language-server = {command = lib.getExe inputs.nil.packages.${pkgs.system}.default;};
    #     config.nil.formatting.command = ["alejandra" "-q"];
    #   }
    # ];
  };
}

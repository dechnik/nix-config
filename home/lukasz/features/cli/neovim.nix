{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    statix
    editorconfig-checker
    deadnix
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
}

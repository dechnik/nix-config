{ config, pkgs, self, inputs, ... }: let
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps;
      [
        python-lsp-server
        pyls-isort
        pytest
        black
        nose
        mypy
        pylama
        flake8
        jupyter
        numpy
        pandas
        tldextract # required by qute-pass
        notebook
        ipykernel
      ]
      ++ python-lsp-server.optional-dependencies.all);
in
{
  imports = [
    inputs.nixcats.homeModule."x86_64-linux"
  ];
  # this value, nixCats is the defaultPackageName you pass to mkNixosModules
  # it will be the namespace for your options.
  nixCats = {
    # these are some of the options. For the rest see
    # :help nixCats.flake.outputs.utils.mkNixosModules
    # you do not need to use every option here, anything you do not define
    # will be pulled from the flake instead.
    enable = true;
    packageName = "nixCats";
  };
  home.packages = with pkgs; [
    pythonEnv
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
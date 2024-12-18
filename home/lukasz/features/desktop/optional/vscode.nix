{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
  ];
  programs.vscode = {
    enable = true;
    extensions =
      with pkgs.vscode-extensions;
      [
        bbenoist.nix # Nix syntax
        jdinhlife.gruvbox
        vscodevim.vim

        ms-vscode-remote.remote-ssh

        matangover.mypy
        # ms-pyright.pyright
        jebbs.plantuml

        # Languages
        tamasfe.even-better-toml
        ms-python.vscode-pylance

        # Nix
        brettm12345.nixfmt-vscode
        b4dm4n.vscode-nixpkgs-fmt

        skyapps.fish-vscode
        redhat.vscode-yaml
        ms-vscode.makefile-tools
        ms-vscode.cmake-tools
        mechatroner.rainbow-csv
        jnoortheen.nix-ide
        github.vscode-pull-request-github
        esbenp.prettier-vscode
        mkhl.direnv
        ms-vscode.cpptools
        # TODO https://github.com/NixOS/nixpkgs/issues/298110
        # ms-python.python
        ms-azuretools.vscode-docker
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # {
        #   name = "cody-ai";
        #   publisher = "sourcegraph";
        #   version = "0.17.1701270418";
        #   # keep this sha for the first run, nix will tell you the correct one to change it to
        #   sha256 = "sha256-iLixgLKz+GAvVSojjWgOEYHzfq2solMlelDUzGEcsCs=";
        # }
      ];
  };
}

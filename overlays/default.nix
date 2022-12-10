{
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Modifies existing packages
  modifications = final: prev: {
    vimPlugins = prev.vimPlugins // {
      vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
        (oldAttrs: rec {
          patches = (oldAttrs.patches or [ ])
            ++ [ ./vim-numbertoggle-command-mode.patch ];
        });
        nvim-treesitter = prev.vimPlugins.nvim-treesitter.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            ./nvim-treesitter-nix-injection.patch
          ];
        });
    } // final.callPackage ../pkgs/vim-plugins { };
    tree-sitter-grammars = prev.tree-sitter-grammars // {
      tree-sitter-nix = prev.tree-sitter-grammars.tree-sitter-nix.overrideAttrs (oldAttrs: {
        src = final.fetchFromGitHub {
          owner = "cstrahan";
          repo = "tree-sitter-nix";
          rev = "1b69cf1fa92366eefbe6863c184e5d2ece5f187d";
          sha256 = "sha256-JaJRikijCXnKAuKA445IIDaRvPzGhLFM29KudaFsSVM=";
        };
      });
    };
    scgit = prev.cgit-pink.overrideAttrs (_oldAttrs: {
      pname = "scgit";
      version = "0.1";
      src = final.fetchFromSourcehut {
        owner = "~lukasz";
        repo = "scgit";
        rev = "2cd05c95827fb94740e876733dc6f7fe88340de2";
        sha256 = "sha256-95mRJ3ZCSkLHqehFQdwM2BY0h+YDhohwpnRiF6/lZtA=";
      };
    });
  };
}

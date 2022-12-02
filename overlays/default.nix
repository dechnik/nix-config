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
  };
}

{ outputs, inputs }:
{
  # Master nixpkgs
  master = final: prev: {
    master = inputs.nixpkgs-master.legacyPackages.${final.system};
  };

  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Modifies existing packages
  modifications = final: prev: {
    vimPlugins = prev.vimPlugins // {
      vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
        (oldAttrs: {
          patches = (oldAttrs.patches or [ ])
            ++ [ ./vim-numbertoggle-command-mode.patch ];
        });
    } // final.callPackage ../pkgs/vim-plugins { };

    xdg-utils-spawn-terminal = prev.xdg-utils.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ./xdg-open-spawn-terminal.diff ];
    });
    khal = prev.khal.overridePythonAttrs (_: {
      doCheck = false;
    });
    todoman = prev.todoman.overridePythonAttrs (_: {
      doCheck = false;
    });
    scgit = prev.cgit-pink.overrideAttrs (_: {
      pname = "scgit";
      version = "0.1";
      src = final.fetchFromSourcehut {
        owner = "~misterio";
        repo = "scgit";
        rev = "2cd05c95827fb94740e876733dc6f7fe88340de2";
        sha256 = "sha256-95mRJ3ZCSkLHqehFQdwM2BY0h+YDhohwpnRiF6/lZtA=";
      };
    });
  };
}

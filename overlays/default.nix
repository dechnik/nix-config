{ outputs, inputs }:
{
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}' or
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs
      (_: flake: (flake.packages or flake.legacyPackages or { }).${final.system} or { })
      inputs;
  };

  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Modifies existing packages
  modifications = final: prev: {
    xdg-utils-spawn-terminal = prev.xdg-utils.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ./xdg-open-spawn-terminal.diff ];
    });

    khal = prev.khal.overridePythonAttrs (_: {
      doCheck = false;
    });

    todoman = prev.todoman.overridePythonAttrs (_: {
      doCheck = false;
    });

    hyprland-displaylink = inputs.hyprland.packages.${prev.system}.hyprland.override {
      wlroots = inputs.hyprland.packages.x86_64-linux.wlroots-hyprland.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./displaylink.patch ];
      });
    };

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

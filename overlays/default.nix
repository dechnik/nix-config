{ outputs, inputs }:
let
  addPatches = pkg: patches: pkg.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ patches;
  });
in {
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
    passExtensions = prev.passExtensions // {
      # https://github.com/tadfisher/pass-otp/pull/173
      pass-otp = addPatches prev.passExtensions.pass-otp [ ./pass-otp-fix-completion.patch ];
    };

    xdg-utils-spawn-terminal = addPatches prev.xdg-utils [ ./xdg-open-spawn-terminal.diff ];

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
  };
}

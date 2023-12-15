{ outputs, inputs }:
let
  addPatches = pkg: patches: pkg.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ patches;
  });
in rec {
  nh = inputs.nh.overlays.default;
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}' or
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs
      (_: flake: let
        legacyPackages = ((flake.legacyPackages or {}).${final.system} or {});
        packages = ((flake.packages or {}).${final.system} or {});
      in
        if legacyPackages != {} then legacyPackages else packages
      )
      inputs;
  };

  # additions = final: _prev: import ../pkgs { pkgs = final; };
  additions = final: prev: import ../pkgs { pkgs = final; } // {
    # vimPlugins = prev.vimPlugins // final.callPackage ../pkgs/vim-plugins { };
    # vimPlugins = prev.vimPlugins // import ../pkgs/vim-plugins {
    #   inherit (final) fetchFromGitHub;
    #   inherit (prev.vimUtils) buildVimPlugin;
    #   inherit (final) sources;
    # };
    sources = prev.callPackage (import ../pkgs/_sources/generated.nix) {};
  };

  # Modifies existing packages
  modifications = final: prev: {
    neovim = inputs.vimconfig.packages."${prev.system}".neovimFull;

    qutebrowser = prev.qutebrowser.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ./qutebrowser-tree-tabs.diff ];
    });

    wasm-bindgen-cli = prev.wasm-bindgen-cli.override {
      version = "0.2.84";
      hash = "sha256-0rK+Yx4/Jy44Fw5VwJ3tG243ZsyOIBBehYU54XP/JGk=";
      cargoHash = "sha256-vcpxcRlW1OKoD64owFF6mkxSqmNrvY+y3Ckn5UwEQ50=";
    };

    passExtensions = prev.passExtensions // {
      # https://github.com/tadfisher/pass-otp/pull/173
      pass-otp = addPatches prev.passExtensions.pass-otp [ ./pass-otp-fix-completion.patch ];
    };

    # https://github.com/mdellweg/pass_secret_service/pull/37
    pass-secret-service = addPatches prev.pass-secret-service [ ./pass-secret-service-native.diff ];

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

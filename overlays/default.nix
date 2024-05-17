{ outputs, inputs }:
let
  addPatches = pkg: patches: pkg.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ patches;
  });
in rec {
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
    # neovim = inputs.vimconfig.packages."${prev.system}".neovimFull;

    wasm-bindgen-cli = prev.wasm-bindgen-cli.override {
      version = "0.2.84";
      hash = "sha256-0rK+Yx4/Jy44Fw5VwJ3tG243ZsyOIBBehYU54XP/JGk=";
      cargoHash = "sha256-vcpxcRlW1OKoD64owFF6mkxSqmNrvY+y3Ckn5UwEQ50=";
    };

    passExtensions = prev.passExtensions // {
      # https://github.com/tadfisher/pass-otp/pull/173
      pass-otp = addPatches prev.passExtensions.pass-otp [ ./pass-otp-fix-completion.patch ];
    };

    # https://github.com/NixOS/nix/issues/7098
    hydra_unstable = addPatches prev.hydra_unstable [ ./hydra-restrict-eval.diff ];

    # https://github.com/mdellweg/pass_secret_service/pull/37
    pass-secret-service = addPatches prev.pass-secret-service [ ./pass-secret-service-native.diff ];

    xdg-utils-spawn-terminal = final.callPackage ../pkgs/xdg-utils { };

    khal = prev.khal.overridePythonAttrs (_: {
      doCheck = false;
    });

    todoman = prev.todoman.overridePythonAttrs (_: {
      doCheck = false;
    });
  };
}

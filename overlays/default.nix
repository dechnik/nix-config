{ outputs, inputs }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
in
rec {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}' or
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs (
      _: flake:
      let
        legacyPackages = ((flake.legacyPackages or { }).${final.system} or { });
        packages = ((flake.packages or { }).${final.system} or { });
      in
      if legacyPackages != { } then legacyPackages else packages
    ) inputs;
  };

  # additions = final: _prev: import ../pkgs { pkgs = final; };
  additions =
    final: prev:
    import ../pkgs { pkgs = final; }
    // {
      # vimPlugins = prev.vimPlugins // final.callPackage ../pkgs/vim-plugins { };
      # vimPlugins = prev.vimPlugins // import ../pkgs/vim-plugins {
      #   inherit (final) fetchFromGitHub;
      #   inherit (prev.vimUtils) buildVimPlugin;
      #   inherit (final) sources;
      # };
      sources = prev.callPackage (import ../pkgs/_sources/generated.nix) { };
    };

  # Modifies existing packages
  modifications = final: prev: {
    # neovim = inputs.vimconfig.packages."${prev.system}".neovimFull;
    ollama-cuda = prev.ollama.override { acceleration = "cuda"; };
    open-webui = prev.open-webui.override {
      python3 = prev.python311.override ({
        packageOverrides = pself: psuper: {
          fake-useragent = psuper.fake-useragent.overridePythonAttrs (_: {
            doCheck = false;
          });
          sentence-transformers = psuper.sentence-transformers.overridePythonAttrs (_: {
            dependencies = _.dependencies ++ [psuper.pillow];
          });
        };
      });
    };

    pythonPackagesExtensions = [(py-final: py-prev: {
      torch = py-final.pytorch-bin;
    })];

    wasm-bindgen-cli = prev.wasm-bindgen-cli.override {
      version = "0.2.84";
      hash = "sha256-0rK+Yx4/Jy44Fw5VwJ3tG243ZsyOIBBehYU54XP/JGk=";
      cargoHash = "sha256-vcpxcRlW1OKoD64owFF6mkxSqmNrvY+y3Ckn5UwEQ50=";
    };

    dart =
      (prev.dart.overrideAttrs (old: {
        version = "3.4.4";
        src = final.fetchurl {
          url = "https://storage.googleapis.com/dart-archive/channels/stable/release/3.4.4/sdk/dartsdk-linux-arm64-release.zip";
          sha256 = "0ih3yx0bjigfbv5dfc262rw3y4ps5pzdilps4k1scb1xhs8y9kml";
        };
      })).override
        { version = "3.4.4"; };

    passExtensions = prev.passExtensions // {
      # https://github.com/tadfisher/pass-otp/pull/173
      pass-otp = addPatches prev.passExtensions.pass-otp [ ./pass-otp-fix-completion.patch ];
    };

    # https://github.com/mdellweg/pass_secret_service/pull/37
    pass-secret-service = addPatches prev.pass-secret-service [ ./pass-secret-service-native.diff ];

    xdg-utils-spawn-terminal = final.callPackage ../pkgs/xdg-utils { };

    khal = prev.khal.overridePythonAttrs (_: {
      doCheck = false;
    });

    # TODO https://github.com/NixOS/nixpkgs/pull/339619
    cudaPackages = prev.cudaPackages_12_3;

    # TODO https://github.com/NixOS/nixpkgs/pull/336901
    olm = prev.olm.overrideAttrs (prev.lib.addMetaAttrs { knownVulnerabilities = [ ]; });

    todoman = prev.todoman.overridePythonAttrs (_: {
      doCheck = false;
    });
    qutebrowser = prev.qutebrowser.overrideAttrs (oldAttrs: {
      preFixup =
        oldAttrs.preFixup
        +
          # Fix for https://github.com/NixOS/nixpkgs/issues/168484
          (
            let
              schemaPath = package: "${package}/share/gsettings-schemas/${package.name}";
            in
            ''
              makeWrapperArgs+=(
                --prefix XDG_DATA_DIRS : ${schemaPath final.gsettings-desktop-schemas}
                --prefix XDG_DATA_DIRS : ${schemaPath final.gtk3}
              )
            ''
          );
      # patches =
      #   (oldAttrs.patches or [])
      #   ++ [
      #     # Repaint tabs when colorscheme changes
      #     ./qutebrowser-refresh-tab-colorscheme.patch
      #     # Reload on SIGHUP
      #     # https://github.com/qutebrowser/qutebrowser/pull/8110
      #     (final.fetchurl {
      #       url = "https://patch-diff.githubusercontent.com/raw/qutebrowser/qutebrowser/pull/8110.patch";
      #       hash = "sha256-W30aGOAy8F/PlfUK2fgJQEcVu5QHcWSus6RKIlvVT1g=";
      #     })
      #   ];
    });
    hydra_unstable =
      (prev.hydra_unstable.overrideAttrs (old: {
        version = "2024-05-23";
        src = final.fetchFromGitHub {
          owner = "nixos";
          repo = "hydra";
          rev = "b3e0d9a8b78d55e5fea394839524f5a24d694230";
          hash = "sha256-WAJJ4UL3hsqsfZ05cHthjEwItnv7Xy84r2y6lzkBMh8=";
        };
        patches = [ ./hydra-restrict-eval.diff ];
      })).override
        { nix = final.nixVersions.nix_2_22; };
  };
}

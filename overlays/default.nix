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
    neovim = inputs.neovim-dechnik.packages."${prev.system}".neovim-dechnik;
    vscode-with-extensions = prev.vscode-with-extensions.override {
      vscodeExtensions = prev.vscode-utils.extensionsFromVscodeMarketplace [
                     {
                        name = "cody-ai";
                        publisher = "sourcegraph";
                        version = "0.15.1696691345";
                        # keep this sha for the first run, nix will tell you the correct one to change it to
                        sha256 = "sha256-IHh7BaZy/z/5LXB+LzKilUS0pZzd3QgkrIgqB7sqHuA=";
                      }
        # Generated from: https://github.com/nixos/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
        ] ++ (with prev.vscode-extensions; [
        bbenoist.nix # Nix syntax
        jdinhlife.gruvbox
        vscodevim.vim

        ms-vscode-remote.remote-ssh

        matangover.mypy
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
      ]) ++ final.lib.optionals (! (final.stdenv.isAarch64 && final.stdenv.isLinux)) (with prev.vscode-extensions; [
        ms-vscode.cpptools
        ms-python.python
        ms-azuretools.vscode-docker
      ]);
    };

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

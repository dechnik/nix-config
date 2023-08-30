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
    vimPlugins = prev.vimPlugins // import ../pkgs/vim-plugins {
      inherit (final) fetchFromGitHub;
      inherit (prev.vimUtils) buildVimPlugin;
      inherit (final) sources;
    };
  };

  # Modifies existing packages
  modifications = final: prev: {
    vscode-with-extensions = prev.vscode-with-extensions.override {
      vscodeExtensions = prev.vscode-utils.extensionsFromVscodeMarketplace [
        # Generated from: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
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
      version = "unstable-2023-08-29";
      src = final.fetchFromGitHub {
        owner = "qutebrowser";
        repo = "qutebrowser";
        rev = "a1842e0226613d67ae8ebe8dd288277be3ad300b";
        hash = "sha256-oAjhzTeZ7TNBR6lxBpNdDGJHnTdnWU16lZtlrvZhfE0=";
      };
      patches = (oldAttrs.patches or [ ]) ++ [ ./qutebrowser-tree-tabs.diff ];
    });

    # TODO downgraded for mu4e
    mu = prev.mu.overrideAttrs (oldAttrs: {
      version = "1.10.4";
      src = final.fetchFromGitHub {
        owner = "djcb";
        repo = "mu";
        rev = "v1.10.4";
        hash = "sha256-vwStqrw/fPYUpBhBsLX0MPXtBtP5LwU0AYmUbP+Ywgo=";
      };
    });

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

{
  description = "My NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org?priority=43"
      "https://nix-community.cachix.org?priority=41"
      "https://cosmic.cachix.org?priority=42"
      "https://cuda-maintainers.cachix.org?priority=44"
      "https://attic.dechnik.net/system?priority=45"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "system:5mtbpEmaoC7RVnZJz/KZU2Of2QXQTMBriCJjt3SK9Iw="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  inputs = {
    # Nix ecossystem
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # clan-core = {
    #   url = "git+https://git.clan.lol/clan/clan-core";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.disko.follows = "disko";
    # };

    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:mic92/sops-nix";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "nixpkgs";
      };
    };
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-protocols = {
      url = "github:hyprwm/hyprland-protocols";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # website = {
    #   url = "github:dechnik/website";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # emacs-overlay.url = "github:nix-community/emacs-overlay/d7d53d728dc68d0fca4601b4e155e746ce274098";
    # emacs-src = {
    #   url = "github:emacs-mirror/emacs/emacs-29";
    #   flake = false;
    # };
    # vimconfig = {
    #   url = "git+https://git.dechnik.net/lukasz/vimconfig.git?ref=master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixcats = {
      url = "github:dechnik/nixCats-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      # you can override input nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
      # you can also override individual plugins
      # for example:
      # inputs.sg-nvim.follows = "sg-nvim"; # <- this will use the obsidian-nvim from your inputs
    };
    sessionx = {
      url = "github:dechnik/tmux-sessionx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    azure-dev-cli.url = "github:dechnik/azure-dev-cli";
    # applet-gpg = {
    #   url = "path:/home/lukasz/Projects/cosmic/cosmic-applet-gpg";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # neovim-dechnik = {
    #   url = "github:dechnik/nvim";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # neovim = {
    #   url = "git+https://git.dechnik.net/lukasz/neovim.git?ref=master";
    # };
  };
  outputs =
    {
      self,
      attic,
      nixpkgs,
      home-manager,
      disko,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
      # forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      # forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
      mkNixos =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit modules;
          extraModules = [
            inputs.colmena.nixosModules.deploymentOptions
            # inputs.disko.nixosModules.disko
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      mkHome =
        modules: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit modules pkgs;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };
      # hydraJobs = import ./hydra.nix { inherit inputs outputs; };
      colmena = import ./colmena.nix { inherit inputs outputs; };

      # packages = forEachPkgs (pkgs: import ./pkgs { inherit pkgs; });
      # devShells = forEachPkgs (pkgs: import ./shell.nix { inherit pkgs; });
      # formatter = forEachPkgs (pkgs: pkgs.nixpkgs-fmt);
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style); # TODO change after official

      nixosConfigurations = {
        "dziad" = mkNixos [ ./hosts/dziad ];
        "ldlat" = mkNixos [ ./hosts/ldlat ];
        "bolek.pve" = mkNixos [ ./hosts/bolek.pve ];
        "lolek.pve" = mkNixos [ ./hosts/lolek.pve ];
        # "olek.pve" = mkNixos [ ./hosts/olek.pve ];
        # "tola.pve" = mkNixos [ ./hosts/tola.pve ];
        "tolek.oracle" = mkNixos [ ./hosts/tolek.oracle ];
        # "ola.hetzner" = mkNixos [ ./hosts/ola.hetzner ];
      };

      homeConfigurations = {
        # Desktop
        "lukasz@dziad" = mkHome [ ./home/lukasz/dziad.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@ldlat" = mkHome [ ./home/lukasz/ldlat.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@bolek" = mkHome [ ./home/lukasz/bolek.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@lolek" = mkHome [ ./home/lukasz/lolek.nix ] nixpkgs.legacyPackages."x86_64-linux";
        # nix build .#homeConfigurations.min.activationPackage 
        "min" = mkHome [ ./home/lukasz/min.nix ] nixpkgs.legacyPackages."x86_64-linux";
        # "lukasz@olek" = mkHome [ ./home/lukasz/olek.nix ] nixpkgs.legacyPackages."x86_64-linux";
        # "lukasz@tola" = mkHome [ ./home/lukasz/tola.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@tolek" = mkHome [ ./home/lukasz/tolek.nix ] nixpkgs.legacyPackages."aarch64-linux";
        # "lukasz@ola" = mkHome [ ./home/lukasz/ola.nix ] nixpkgs.legacyPackages."x86_64-linux";
      };

    };
}

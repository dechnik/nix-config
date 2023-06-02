{
  description = "My NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.dechnik.net"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.dechnik.net:VM4JPWTGlfhOxnJsFk1r325lDewW44eyZ32ivqPaFJQ="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Nix ecossystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

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

    hydra.url = "github:nixos/hydra";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    hyprland.url = "github:hyprwm/hyprland";
    hyprwm-contrib.url = "github:hyprwm/contrib";
    hyprland-protocols = {
      url = "github:hyprwm/hyprland-protocols";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lldap.url = "github:dechnik/lldap";
    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprland-protocols.follows = "hyprland-protocols";
    };

    website.url = "sourcehut:~lukasz/website/master";
    emacs-overlay.url = "github:nix-community/emacs-overlay/d7d53d728dc68d0fca4601b4e155e746ce274098";
    emacs-src = {
      url = "github:emacs-mirror/emacs/emacs-29";
      flake = false;
    };
    grafana-matrix-forwarder = {
      url = "git+https://git.dechnik.net/lukasz/grafana-matrix-forwarder.git?ref=main";
    };
    neovim = {
      url = "git+https://git.dechnik.net/lukasz/neovim.git?ref=master";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
      mkNixos = modules: nixpkgs.lib.nixosSystem {
        inherit modules;
        specialArgs = { inherit inputs outputs; };
      };
      mkHome = modules: pkgs: home-manager.lib.homeManagerConfiguration {
        inherit modules pkgs;
        extraSpecialArgs = { inherit inputs outputs; };
      };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };
      hydraJobs = import ./hydra.nix { inherit inputs outputs; };
      colmena = import ./colmena.nix { inherit inputs outputs; };

      packages = forEachPkgs (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachPkgs (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachPkgs (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        "dziad" = mkNixos [ ./hosts/dziad ];
        "ldlat" = mkNixos [ ./hosts/ldlat ];
        "bolek.pve" = mkNixos [ ./hosts/bolek.pve ];
        "lolek.pve" = mkNixos [ ./hosts/lolek.pve ];
        "k3sserver1.pve" = mkNixos [ ./hosts/k3sserver1.pve ];
        "k3sagent1.pve" = mkNixos [ ./hosts/k3sagent1.pve ];
        "k3sagent2.pve" = mkNixos [ ./hosts/k3sagent2.pve ];
        "tola.pve" = mkNixos [ ./hosts/tola.pve ];
        "olek.pve" = mkNixos [ ./hosts/olek.pve ];
        "tolek.oracle" = mkNixos [ ./hosts/tolek.oracle ];
        "ola.hetzner" = mkNixos [ ./hosts/ola.hetzner ];
      };

      homeConfigurations = {
        # Desktop
        "lukasz@dziad" = mkHome [ ./home/lukasz/dziad.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@ldlat" = mkHome [ ./home/lukasz/ldlat.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@bolek" = mkHome [ ./home/lukasz/bolek.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@lolek" = mkHome [ ./home/lukasz/lolek.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@k3sserver1" = mkHome [ ./home/lukasz/k3sserver1.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@k3sagent1" = mkHome [ ./home/lukasz/k3sagent1.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@k3sagent2" = mkHome [ ./home/lukasz/k3sagent2.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@tola" = mkHome [ ./home/lukasz/tola.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@olek" = mkHome [ ./home/lukasz/olek.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "lukasz@tolek" = mkHome [ ./home/lukasz/tolek.nix ] nixpkgs.legacyPackages."aarch64-linux";
        "lukasz@ola" = mkHome [ ./home/lukasz/ola.nix ] nixpkgs.legacyPackages."x86_64-linux";
      };

    };
}

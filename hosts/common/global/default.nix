{ pkgs, lib, inputs, outputs, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./acme.nix
    ./avahi.nix
    ./fail2ban.nix
    ./firewall.nix
    ./fish.nix
    ./zsh.nix
    ./locale.nix
    # ./tailscale.nix
    ./nix.nix
    ./openssh.nix
    ./podman.nix
    ./postgres.nix
    ./sops.nix
    ./ssh-serve-store.nix
    ./fonts.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git
      pciutils
      #nextcloud-client
    ];

    # Persist logs, timers, etc
    persistence = {
      "/persist".directories = [ "/var/lib/systemd" "/var/log" "/srv" ];
    };

    enableAllTerminfo = true;
  };

  # security.sudo.wheelNeedsPassword = false;

  # Allows users to allow others on their binds
  programs.fuse.userAllowOther = true;

  hardware.enableRedistributableFirmware = true;
  networking.domain = "dechnik.net";

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];
}

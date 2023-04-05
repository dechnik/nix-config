{ pkgs, inputs, outputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./acme.nix
    ./fail2ban.nix
    ./firewall.nix
    ./fish.nix
    ./zsh.nix
    ./systemd-initrd.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./network.nix
    ./optin-persistence.nix
    ./postgres.nix
    ./sops.nix
    ./ssh-serve-store.nix
    ./fonts.nix
    ./tmp.nix
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

    enableAllTerminfo = true;
  };

  # security.sudo.wheelNeedsPassword = false;

  hardware.enableRedistributableFirmware = true;

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

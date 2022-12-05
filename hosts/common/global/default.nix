{ pkgs, lib, inputs, outputs, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./acme.nix
    ./fish.nix
    ./zsh.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./sops.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  networking.domain = "dechnik.net";

  environment = {
    systemPackages = with pkgs; [
      git
      #nextcloud-client
    ];
    loginShellInit = ''
      # Activate home-manager environment, if not already
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';

    # Persist logs, timers, etc
    persistence = {
      "/persist".directories = [ "/var/lib/systemd" "/var/log" "/srv" ];
    };

    # Add terminfo files
    enableAllTerminfo = true;
  };

  # security.sudo.wheelNeedsPassword = false;

  # Allows users to allow others on their binds
  programs.fuse.userAllowOther = true;

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

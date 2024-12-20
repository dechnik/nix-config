{
  pkgs,
  inputs,
  outputs,
  ...
}:
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
    ./podman.nix
    ./optin-persistence.nix
    ./sops.nix
    ./ssh-serve-store.nix
    ./fonts.nix
    ./tmp.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };
  # Fix for qt6 plugins
  # TODO: maybe upstream this?
  environment.profileRelativeSessionVariables = {
    QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
    # QT_PLUGIN_PATH = [
    #   "${pkgs.qt5.qtbase}/${pkgs.qt5.qtbase.qtPluginPrefix}"
    #   "${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"
    #   "${pkgs.qt6.qtwayland}/lib/qt-6/plugins"
    #   "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
    # ];
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
      parted
      restic
      mdadm
      nfs-utils
      nixos-shell
      zerotierone
      #nextcloud-client
    ];

    #TODO check if contour is not broken
    enableAllTerminfo = false;
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

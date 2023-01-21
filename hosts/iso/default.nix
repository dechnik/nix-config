{ pkgs, config, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    ./setup-zfs.nix
  ];

  # use the latest Linux kernel
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  nixpkgs.hostPlatform.system = "x86_64-linux";

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs" ];
  nix = {
    # FIXME: Workaround for https://github.com/NixOS/nixpkgs/issues/124215
    # sandboxPaths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  environment.systemPackages = with pkgs;
    [
      git
    ];
  isoImage.contents = [
    ## Use --impure to solve error: "error: access to path is forbidden in restricted mode"
    { source = /home/lukasz/Projects/nix-config;
    ## self doesn't work.
    # { source = self;
      target = "/nixcfg/"; # /iso/nixcfg
    }
  ];
}

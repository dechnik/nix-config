{ pkgs, config, lib, outputs, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.lukasz = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ] ++ ifTheyExist [
      "network"
      "wireshark"
      "i2c"
      "mysql"
      "docker"
      "podman"
      "git"
      "libvirtd"
      "deluge"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPX+YNQ780Dt8kG7lMcFKQRXCCWCm/9cMTq72y94oVV6 (none)"
    ];

    passwordFile = config.sops.secrets.lukasz-password.path;
  };

  sops.secrets.lukasz-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };


  services.geoclue2.enable = true;
  security.pam.services = { swaylock = { }; };
}

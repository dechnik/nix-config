{ pkgs, config, lib, outputs, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.lukasz = {
    isNormalUser = true;
    shell = pkgs.zsh;
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIoesh7W8TLj9mw+WquNWgeLnQ9FHxh+5ZkPNrObXnv (none)"
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

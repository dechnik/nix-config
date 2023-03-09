{ config, ... }:
{
  nix = {
    sshServe = {
      enable = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhDh8CMMyRIPUKJkRinxdjG3bgebxq/ETia4leBR8R0 nix-ssh"
      ];
      protocol = "ssh";
      write = true;
    };
    settings.trusted-users = [ "nix-ssh" ];
  };
}

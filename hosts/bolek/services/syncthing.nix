{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    user = "lukasz";
    group = "users";
    dataDir = "/media/syncthing";
    configDir = "/media/syncthing/.config";
    openDefaultPorts = true;
  };
}

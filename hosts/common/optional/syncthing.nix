{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    user = "lukasz";
    group = "users";
    key = "/run/syncthing-key.pem";
    cert = "/run/syncthing-cert.pem";
    # dataDir = "/media/syncthing";
    # configDir = "/media/syncthing/.config";
    openDefaultPorts = true;
    devices = {
      dziad = {
        id = "G2UU2SO-ETG3TAS-D2WXFDU-YZN3DTM-YQCB6I2-DMHKYD5-Q2XDJ3T-Y4LMCQI";
        name = "dziad";
        introducer = true;
      };
    };
    folders = {
      "/persist/home/lukasz/Downloads" = {
        id = "persistent-home-downloads";
        devices = [ "dziad" ];
      };
      "/persist/home/lukasz/Documents" = {
        id = "persistent-home-documents";
        devices = [ "dziad" ];
      };
      "/persist/home/lukasz/Music" = {
        id = "persistent-home-music";
        devices = [ "dziad" ];
      };
      "/persist/home/lukasz/Pictures" = {
        id = "persistent-home-pictures";
        devices = [ "dziad" ];
      };
      "/persist/home/lukasz/Org" = {
        id = "persistent-home-org";
        devices = [ "dziad" ];
      };
      "/persist/home/lukasz/Roam" = {
        id = "persistent-home-roam";
        devices = [ "dziad" ];
      };
    };
  };
}

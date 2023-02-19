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
      bolek = {
        id = "G2UU2SO-ETG3TAS-D2WXFDU-YZN3DTM-YQCB6I2-DMHKYD5-Q2XDJ3T-Y4LMCQI";
        name = "bolek";
        introducer = false;
      };
    };
    folders = {
      "/persist/home/lukasz/Downloads" = {
        id = "persistent-home-downloads";
        devices = [ "bolek" ];
      };
      "/persist/home/lukasz/Documents" = {
        id = "persistent-home-documents";
        devices = [ "bolek" ];
      };
      "/persist/home/lukasz/Music" = {
        id = "persistent-home-music";
        devices = [ "bolek" ];
      };
      "/persist/home/lukasz/Pictures" = {
        id = "persistent-home-pictures";
        devices = [ "bolek" ];
      };
      "/persist/home/lukasz/Org" = {
        id = "persistent-home-org";
        devices = [ "bolek" ];
      };
      "/persist/home/lukasz/Roam" = {
        id = "persistent-home-roam";
        devices = [ "bolek" ];
      };
    };
  };
  sops.secrets = {
    syncthing-cert = {
      sopsFile = ../secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/syncthing-cert.pem";
    };
    syncthing-key = {
      sopsFile = ../secrets.yaml;
      owner = "lukasz";
      mode = "0400";
      path = "/run/syncthing-key.pem";
    };
  };
}

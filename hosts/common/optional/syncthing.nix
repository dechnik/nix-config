{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    user = "lukasz";
    group = "users";
    key = "/run/syncthing-key.pem";
    cert = "/run/syncthing-cert.pem";
    overrideDevices = true;
    overrideFolders = true;
    # dataDir = "/media/syncthing";
    # configDir = "/media/syncthing/.config";
    extraOptions = {
      gui = {
        theme = "black";
      };
      options = {
        listenAddress = "tcp://0.0.0.0:22000,quic://0.0.0.0:22000";
        globalAnnounceEnabled = false;
      };
    };
    openDefaultPorts = true;
    devices = {
      dziad = {
        id = "G2UU2SO-ETG3TAS-D2WXFDU-YZN3DTM-YQCB6I2-DMHKYD5-Q2XDJ3T-Y4LMCQI";
        name = "dziad";
        introducer = false;
      };
      bolek = {
        id = "WNVA2CT-I6VRIU4-WA47OW7-M7COY47-S2L7DN6-TOHVAUI-5RF37T2-Y3DINAQ";
        name = "bolek";
        introducer = false;
      };
    };
    folders = {
      "/persist/home/lukasz/Downloads" = {
        id = "persistent-home-downloads";
        devices = [ "dziad" "bolek" ];
      };
      "/persist/home/lukasz/Documents" = {
        id = "persistent-home-documents";
        devices = [ "dziad" "bolek" ];
      };
      "/persist/home/lukasz/Music" = {
        id = "persistent-home-music";
        devices = [ "dziad" "bolek" ];
      };
      "/persist/home/lukasz/Pictures" = {
        id = "persistent-home-pictures";
        devices = [ "dziad" "bolek" ];
      };
      "/persist/home/lukasz/Org" = {
        id = "persistent-home-org";
        devices = [ "dziad" "bolek" ];
      };
      "/persist/home/lukasz/Roam" = {
        id = "persistent-home-roam";
        devices = [ "dziad" "bolek" ];
      };
    };
  };
}

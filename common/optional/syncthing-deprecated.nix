{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.persistence."/persist" = {
    hideMounts = true;
    users.lukasz = {
      directories = [ ".config/syncthing" ];
    };
  };
  services.syncthing = {
    enable = true;
    user = "lukasz";
    group = "users";
    key = "/run/syncthing-key.pem";
    cert = "/run/syncthing-cert.pem";
    configDir = "/home/lukasz/.config/syncthing";
    overrideFolders = true;
    overrideDevices = true;
    extraOptions = {
      gui = {
        theme = "black";
      };
      options = {
        globalAnnounceEnabled = true;
        natEnabled = true;
      };
    };
    openDefaultPorts = true;
    devices = {
      dziad = {
        id = "G2UU2SO-ETG3TAS-D2WXFDU-YZN3DTM-YQCB6I2-DMHKYD5-Q2XDJ3T-Y4LMCQI";
        name = "dziad";
        addresses = [ "tcp://dziad:22000" ];
      };
      ldlat = {
        id = "HQ2AMMU-YNEC5XM-V2PPJ4A-WMSM7D3-HHEGC7C-XBOYK4E-SKEE2VE-UG337AF";
        name = "ldlat";
        addresses = [ "tcp://ldlat:22000" ];
      };
      bolek = {
        id = "WNVA2CT-I6VRIU4-WA47OW7-M7COY47-S2L7DN6-TOHVAUI-5RF37T2-Y3DINAQ";
        name = "bolek";
        addresses = [ "tcp://bolek:22000" ];
      };
      moto = {
        id = "OXLWOWF-NEWT75R-EPLET5W-NJUFJPV-WKIRLRK-UKBP442-6Z5H4HP-ZTCE7QO";
        name = "moto";
      };
    };
    folders = {
      "/persist/home/lukasz/Downloads" = {
        id = "persistent-home-downloads";
        devices = [
          "dziad"
          "bolek"
          "ldlat"
        ];
      };
      "/persist/home/lukasz/Documents" = {
        id = "persistent-home-documents";
        devices = [
          "dziad"
          "bolek"
          "ldlat"
        ];
      };
      "/persist/home/lukasz/Music" = {
        id = "persistent-home-music";
        devices = [
          "dziad"
          "bolek"
          "ldlat"
        ];
      };
      "/persist/home/lukasz/Pictures" = {
        id = "persistent-home-pictures";
        devices = [
          "dziad"
          "bolek"
          "ldlat"
        ];
      };
      "/persist/home/lukasz/Org" = {
        id = "persistent-home-org";
        devices = [
          "dziad"
          "bolek"
          "ldlat"
          "moto"
        ];
      };
      "/persist/home/lukasz/Roam" = {
        id = "persistent-home-roam";
        devices = [
          "dziad"
          "bolek"
          "ldlat"
          "moto"
        ];
      };
    };
  };
}

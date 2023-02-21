{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    user = "lukasz";
    group = "users";
    overrideFolders = false;
    overrideDevices = true;
    extraOptions = {
      gui = {
        theme = "black";
      };
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
    };
    openDefaultPorts = true;
    devices = {
      dziad = {
        id = "G2UU2SO-ETG3TAS-D2WXFDU-YZN3DTM-YQCB6I2-DMHKYD5-Q2XDJ3T-Y4LMCQI";
        name = "dziad";
      };
      ldlat = {
        id = "HQ2AMMU-YNEC5XM-V2PPJ4A-WMSM7D3-HHEGC7C-XBOYK4E-SKEE2VE-UG337AF";
        name = "ldlat";
      };
      bolek = {
        id = "WNVA2CT-I6VRIU4-WA47OW7-M7COY47-S2L7DN6-TOHVAUI-5RF37T2-Y3DINAQ";
        name = "bolek";
      };
    };
    folders = {
      "/persist/home/lukasz/Downloads" = {
        id = "persistent-home-downloads";
        devices = [ "dziad" "bolek" "ldlat" ];
      };
      "/persist/home/lukasz/Documents" = {
        id = "persistent-home-documents";
        devices = [ "dziad" "bolek" "ldlat" ];
      };
      "/persist/home/lukasz/Music" = {
        id = "persistent-home-music";
        devices = [ "dziad" "bolek" "ldlat" ];
      };
      "/persist/home/lukasz/Pictures" = {
        id = "persistent-home-pictures";
        devices = [ "dziad" "bolek" "ldlat" ];
      };
      "/persist/home/lukasz/Org" = {
        id = "persistent-home-org";
        devices = [ "dziad" "bolek" "ldlat" ];
      };
      "/persist/home/lukasz/Roam" = {
        id = "persistent-home-roam";
        devices = [ "dziad" "bolek" "ldlat" ];
      };
    };
  };
}

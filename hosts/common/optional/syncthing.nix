{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    user = "lukasz";
    group = "users";
    configDir = "/home/lukasz/.config/syncthing";
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
        id = "MGREPZ7-UJS7KZL-OPKY7CP-JYBG7Y6-Y73VUQX-7FUGV63-YZS5BIB-LEHWQAX";
        name = "dziad";
      };
      ldlat = {
        id = "HQ2AMMU-YNEC5XM-V2PPJ4A-WMSM7D3-HHEGC7C-XBOYK4E-SKEE2VE-UG337AF";
        name = "ldlat";
      };
      bolek = {
        id = "LVYEKHX-5Q2EPHS-6PHD5ZV-N5L3LAU-Z4AKWAS-7U6NFTY-EO4UPLK-SZ5PBQS";
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

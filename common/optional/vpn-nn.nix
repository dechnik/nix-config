{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
  networking = {
    networkmanager.plugins = with pkgs; [
      networkmanager-l2tp
      networkmanager-openvpn
      networkmanager_strongswan
    ];
  };
}

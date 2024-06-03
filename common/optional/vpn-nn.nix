{ pkgs, ... }:
{
  networking = {
    networkmanager.plugins = with pkgs; [
      networkmanager-l2tp
      networkmanager-openvpn
      networkmanager_strongswan
    ];
  };
}

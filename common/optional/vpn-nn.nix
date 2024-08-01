{ pkgs, ... }:
{
  sops.secrets = {
    ipsec-secrets = {
      sopsFile = ../secrets.yaml;
      path = "/etc/ipsec.secrets";
    };
  };
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

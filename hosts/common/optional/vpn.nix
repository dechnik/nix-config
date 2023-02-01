{ config, lib, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 1701 ];
  networking.firewall.allowedUDPPorts = [ 1701 500 4500 ];
  services.xl2tpd = {
    enable = true;
  };
  sops.secrets = {
    l2tp-ebi-conn = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
    l2tp-ebi-options = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
    ipsec-secrets = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };
}

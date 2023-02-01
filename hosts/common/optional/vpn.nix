{ config, lib, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 1701 ];
  networking.firewall.allowedUDPPorts = [ 1701 500 4500 ];
  services.xl2tpd = {
    enable = true;
    # extraXl2tpOptions = ''
    #   ${builtins.readFile config.sops.secrets.l2tp-ebi-conn.path}
    # '';
  };
  services.strongswan = {
    enable = false;
    secrets = [
      "ipsec.d/*.secrets"
    ];
  };
  sops.secrets = {
    l2tp-conn = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
    l2tp-ebi-options = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
      path = "/etc/ppp/options.l2tpd.ebi";
    };
    ipsec-secrets = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
      path = "/etc/ipsec.d/my.secrets";
    };
  };
}

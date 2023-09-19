{ config, lib, pkgs, ... }:
let
  xl2tpd-ppp-wrapped = pkgs.stdenv.mkDerivation {
    name = "xl2tpd-ppp-wrapped";
    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.ppp}/sbin/pppd $out/bin/pppd \
        --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
        --set NIX_REDIRECTS "/etc/ppp=/etc/xl2tpd/ppp"
      makeWrapper ${pkgs.xl2tpd}/bin/xl2tpd $out/bin/xl2tpd \
        --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
        --set NIX_REDIRECTS "${pkgs.ppp}/sbin/pppd=$out/bin/pppd"
    '';
  };
  swanctl = pkgs.writeShellScriptBin "swanctl" ''
    exec ${config.services.strongswan-swanctl.package}/bin/swanctl "$@"
  '';
in
{
  environment.systemPackages = [
    swanctl
    pkgs.strongswan
  ];
  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [ 1701 ];
    allowedUDPPorts = [ 1701 500 4500 ];
    # extraInputRules = ''
    #   ip protocol { ah, esp } accept
    #   meta ipsec exists meta l4proto { tcp, udp } th dport 53 accept
    # '';
    # extraForwardRules = ''
    #   meta ipsec exists accept
    #   rt ipsec exists accept
    # '';
  };
  services.xl2tpd = {
    enable = true;
  };
  systemd.services.xl2tpd.serviceConfig.ExecStart = lib.mkForce "${xl2tpd-ppp-wrapped}/bin/xl2tpd -D -c /etc/xl2tpd/xl2tpd.conf -p /run/xl2tpd/pid -C /run/xl2tpd/control";
  # services.strongswan-swanctl.enable = true;
  # services.strongswan-swanctl.strongswan.extraConfig = ''
  #   charon {
  #     install_routes = no
  #   }
  # '';
  # environment.etc."swanctl/swanctl.conf".enable = false;
  # system.activationScripts.strongswan-swanctl-secret-conf = lib.stringAfter [ "etc" ] ''
  #   mkdir -p /etc/swanctl
  #   ln -sf ${config.sops.secrets.swanctl.path} /etc/swanctl/swanctl.conf
  # '';
  services.strongswan = {
    enable = true;
    secrets = [
      "/etc/ipsec.d/*.secrets"
    ];
  };
  systemd.services.strongswan.environment.STRONGSWAN_CONF = lib.mkForce "/run/secrets/strongswan-config";
  sops.secrets = {
    l2tp-config = {
      sopsFile = ../secrets.yaml;
      path = "/etc/xl2tpd/xl2tpd.conf";
    };
    l2tp-ant-options = {
      sopsFile = ../secrets.yaml;
    };
    # l2tp-ebi-options = {
    #   sopsFile = ../secrets.yaml;
    #   path = "/etc/ppp/options.l2tpd.ebi";
    # };
    # swanctl = {
    #   sopsFile = ../secrets.yaml;
    # };
    ipsec-secrets = {
      sopsFile = ../secrets.yaml;
      path = "/etc/ipsec.d/my.secrets";
    };
    ipsec-config = {
      sopsFile = ../secrets.yaml;
      path = "/etc/ipsec.conf";
    };
    strongswan-config = {
      sopsFile = ../secrets.yaml;
    };
  };
}

{ config, lib, pkgs, ... }:
let
  xl2tpd-ppp-wrapped = pkgs.stdenv.mkDerivation {
    name         = "xl2tpd-ppp-wrapped";
    phases       = [ "installPhase" ];
    nativeBuildInputs  = with pkgs; [ makeWrapper ];
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
in
{
  networking.firewall.allowedTCPPorts = [ 1701 ];
  networking.firewall.allowedUDPPorts = [ 1701 500 4500 ];
  services.xl2tpd = {
    enable = true;
  };
  systemd.services.xl2tpd.serviceConfig.ExecStart = lib.mkForce "${xl2tpd-ppp-wrapped}/bin/xl2tpd -D -c /etc/xl2tpd/xl2tpd.conf -s /etc/xl2tpd/l2tp-secrets -p /run/xl2tpd/pid -C /run/xl2tpd/control";
  services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.d/*.secrets"
    ];
  };
  sops.secrets = {
    l2tp-config = {
      sopsFile = ../secrets.yaml;
      path = "/etc/xl2tpd/xl2tpd.conf";
    };
    l2tp-ebi-options = {
      sopsFile = ../secrets.yaml;
      path = "/etc/ppp/options.l2tpd.ebi";
    };
    ipsec-secrets = {
      sopsFile = ../secrets.yaml;
      path = "/etc/ipsec.d/my.secrets";
    };
  };
}

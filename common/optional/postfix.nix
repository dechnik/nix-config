{ pkgs
, lib
, config
, ...
}:
let
  consul = import ../functions/consul.nix {inherit lib;};
in
{
  sops.secrets = {
    sasl-password = {
      sopsFile = ../secrets.yaml;
      mode = "0600";
      path = "/etc/postfix.local/sasl_passwd";
    };
  };
  services.postfix = {
    enable = true;
    hostname = "${config.networking.hostName}.${config.networking.domain}";
    setSendmail = true;
    relayHost = "mail.dechnik.net";
    relayPort = 587;
    extraConfig = ''
      smtp_use_tls=yes
      smtp_sasl_auth_enable=yes
      smtp_tls_CAfile=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      smtp_sasl_password_maps=hash:/etc/postfix.local/sasl_passwd
      smtp_sasl_security_options=noanonymous
    '';
  };
  systemd.services.postfix.preStart = "${pkgs.postfix}/sbin/postmap /etc/postfix.local/sasl_passwd";

  services.prometheus.exporters.postfix = {
    enable = true;
    openFirewall = true;
  };

  my.consulServices.postfix_exporter = consul.prometheusExporter "postfix" config.services.prometheus.exporters.postfix.port;
}

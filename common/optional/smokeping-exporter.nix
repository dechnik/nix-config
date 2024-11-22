{ config, lib, ... }:
let
  consul = import ../functions/consul.nix { inherit lib; };
in
{
  services.prometheus.exporters.smokeping = {
    enable = true;
    openFirewall = true;

    hosts = [
      "bolek.pve.dechnik.net"
      # "consul.hetzner.dechnik.net"
      "consul.oracle.dechnik.net"
      # "core.ntnu.fap.no"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  systemd.services."prometheus-smokeping-exporter" = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  my.consulServices.smokeping_exporter = consul.prometheusExporter "smokeping" config.services.prometheus.exporters.smokeping.port;
}

{ config, lib, ... }:
let
  consul = import ../functions/consul.nix { inherit lib; };
in
{
  services.prometheus.exporters.systemd = {
    enable = true;
    openFirewall = true;
    extraFlags = [ "--systemd.collector.unit-exclude=builder-pinger.service" ];
  };

  my.consulServices.systemd_exporter = consul.prometheusExporter "systemd" config.services.prometheus.exporters.systemd.port;
}

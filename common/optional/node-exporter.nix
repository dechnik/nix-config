{ config, lib, ... }:
let
  consul = import ../functions/consul.nix { inherit lib; };
in
{
  services.prometheus.exporters.node = lib.mkIf (!config.boot.isContainer) {
    enable = true;
    enabledCollectors = [ "systemd" ];
  };

  networking.firewall.interfaces."${config.my.lan}".allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];

  my.consulServices.node_exporter = consul.prometheusExporter "node" config.services.prometheus.exporters.node.port;
}

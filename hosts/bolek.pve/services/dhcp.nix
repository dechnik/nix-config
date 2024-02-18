{ lib, config, ... }:
let
  consul = import ../../../common/functions/consul.nix { inherit lib; };
in
{
  # services.dhcpd4 = {
  #   enable = true;
  #   interfaces = [ config.my.lan ];
  #   extraConfig = ''
  #     option subnet-mask 255.255.255.0;
  #     subnet 10.60.0.0 netmask 255.255.255.0 {
  #       option broadcast-address 10.60.0.255;
  #       option domain-name-servers 10.60.0.1;
  #       option routers 10.60.0.1;
  #       interface ${config.my.lan};
  #       range 10.60.0.171 10.60.0.250;
  #     }
  #   '';
  #   machines = [
  #   ];
  # };
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          config.my.lan
        ];
      };
      control-socket = {
        socket-type = "unix";
        socket-name = "/tmp/kea-dhcp4.socket";
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          pools = [
            {
              pool = "10.60.0.171 - 10.60.0.250";
            }
          ];
          subnet = "10.60.0.0/24";
        }
      ];
      valid-lifetime = 4000;
    };
  };

  services.prometheus.exporters.kea = {
    enable = true;
    openFirewall = true;
    controlSocketPaths = [
      "/tmp/kea-dhcp4.socket"
    ];
  };

  my.consulServices.kea_exporter = consul.prometheusExporter "kea" config.services.prometheus.exporters.kea.port;

}

{
  config,
  lib,
  pkgs,
  ...
}: let
  consul = import ../functions/consul.nix {inherit lib;};
in {
  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      clientMaxBodySize = "300m";
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # services.prometheus.exporters.nginx = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # my.consulServices.nginx_exporter = consul.prometheusExporter "nginx" config.services.prometheus.exporters.nginx.port;
  services.prometheus.exporters.nginxlog = {
    enable = true;
    openFirewall = true;

    group = "nginx";
    user = "nginx";

    settings = {
      namespaces = let
        # format = ''
        #   $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
        # '';
        mkApp = domain: {
          name = domain;
          metrics_override = {prefix = "nginxlog";};
          source.files = ["/var/log/nginx/${domain}.access.log"];
          namespace_label = "vhost";
        };
      in
        [
          {
            name = "catch";
            metrics_override = {prefix = "nginxlog";};
            source.files = ["/var/log/nginx/access.log"];
            namespace_label = "vhost";
          }
        ]
        ++ builtins.map mkApp (builtins.attrNames config.services.nginx.virtualHosts);
    };
  };

  my.consulServices.nginxlog_exporter = consul.prometheusExporter "nginxlog" config.services.prometheus.exporters.nginxlog.port;
}

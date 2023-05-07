{ config
, lib
, pkgs
, ...
}:
let
  consul = import ../functions/consul.nix { inherit lib; };
in
{
  imports = [
    ../../modules/nixos/tailscale-nginx-auth.nix
  ];
  services.tailscale-nginx-auth.enable = true;
  users.users.nginx.extraGroups = [ "acme" ];
  services = {
    nginx = {
      enable = true;

      statusPage = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = false;
      # proxy_redirect          off;
      # proxy_connect_timeout   60s;
      # proxy_send_timeout      60s;
      # proxy_read_timeout      60s;
      # proxy_http_version      1.1;
      # # don't let clients close the keep-alive connection to upstream. See the nginx blog for details:
      # # https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
      # proxy_set_header        "Connection" "";
      # proxy_set_header        Host $host;
      # proxy_set_header        X-Real-IP $remote_addr;
      # proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      # proxy_set_header        X-Forwarded-Proto $scheme;
      # proxy_set_header        X-Forwarded-Host $host;
      # proxy_set_header        X-Forwarded-Server $host;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      clientMaxBodySize = "300m";
      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      commonHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        # map $scheme $hsts_header {
        #     https   "max-age=31536000; includeSubdomains; preload";
        # }
        # add_header Strict-Transport-Security $hsts_header;
        # Enable CSP for your services.
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;
        # Minimize information leaked to other domains
        # add_header 'Referrer-Policy' 'origin-when-cross-origin';
        # Disable embedding as a frame
        # add_header X-Frame-Options DENY;
        # Prevent injection of code in other mime types (XSS Attacks)
        # add_header X-Content-Type-Options nosniff;
        # Enable XSS protection of the browser.
        # May be unnecessary when CSP is configured properly (see above)
        # add_header X-XSS-Protection "1; mode=block";
        # This might create errors
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
      '';
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
      namespaces =
        let
          # format = ''
          #   $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
          # '';
          mkApp = domain: {
            name = domain;
            metrics_override = { prefix = "nginxlog"; };
            source.files = [ "/var/log/nginx/${domain}.access.log" ];
            namespace_label = "vhost";
          };
        in
        [
          {
            name = "catch";
            metrics_override = { prefix = "nginxlog"; };
            source.files = [ "/var/log/nginx/access.log" ];
            namespace_label = "vhost";
          }
        ]
        ++ builtins.map mkApp (builtins.attrNames config.services.nginx.virtualHosts);
    };
  };

  my.consulServices.nginxlog_exporter = consul.prometheusExporter "nginxlog" config.services.prometheus.exporters.nginxlog.port;
}

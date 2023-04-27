{ pkgs, lib, config, outputs, inputs, ... }:
let
  hydraUser = config.users.users.hydra.name;
  hydraGroup = config.users.users.hydra.group;

  release-host-branch = pkgs.callPackage ./lib/release-host-branch.nix {
    sshKeyFile = config.sops.secrets.nix-ssh-key.path;
  };
in
{
  imports = [
    inputs.hydra.nixosModules.hydra
    ./machines.nix
  ];
  security.acme.certs = {
    "hydra.dechnik.net" = {
      group = "nginx";
    };
  };

  # https://github.com/NixOS/nix/issues/5039
  nix.extraOptions = ''
    allowed-uris = https:// http://
  '';
  # https://github.com/NixOS/nix/issues/4178#issuecomment-738886808
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";

  services = {
    hydra = {
      enable = true;
      package = pkgs.inputs.hydra.hydra;
      hydraURL = "https://hydra.dechnik.net";
      notificationSender = "monitoring@dechnik.net";
      listenHost = "localhost";
      smtpHost = "localhost";
      useSubstitutes = true;
      extraConfig = /* xml */ ''
        max_unsupported_time = 30
        <runcommand>
          job = nix-config:main:*
          command = ${lib.getExe release-host-branch} >> /tmp/hydra/release.log 2>&1
        </runcommand>
      '';
      extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
    };
    nginx.virtualHosts = {
      "hydra.dechnik.net" = {
        forceSSL = true;
        useACMEHost = "hydra.dechnik.net";
        extraConfig = ''
          access_log /var/log/nginx/hydra.dechnik.net.access.log;
        '';
        locations = {
          "/" = {
            proxyPass =
              "http://localhost:${toString config.services.hydra.port}";
            extraConfig = ''
              proxy_redirect          off;
              proxy_connect_timeout   60s;
              proxy_send_timeout      60s;
              proxy_read_timeout      60s;
              proxy_http_version      1.1;
              # don't let clients close the keep-alive connection to upstream. See the nginx blog for details:
              # https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
              proxy_set_header        "Connection" "";
              proxy_set_header        Host $host;
              proxy_set_header        X-Real-IP $remote_addr;
              proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header        X-Forwarded-Proto $scheme;
              proxy_set_header        X-Forwarded-Host $host;
              proxy_set_header        X-Forwarded-Server $host;
            '';
          };
        };
      };
    };
  };
  users.users = {
    hydra-queue-runner.extraGroups = [ hydraGroup ];
    hydra-www.extraGroups = [ hydraGroup ];
  };
  sops.secrets = {
    nix-ssh-key = {
      sopsFile = ../../secrets.yaml;
      owner = hydraUser;
      group = hydraGroup;
      mode = "0440";
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/hydra" ];
  };
}

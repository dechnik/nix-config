{ config, ... }:
let
  hydraUser = config.users.users.hydra.name;
  hydraGroup = config.users.users.hydra.group;

  # Make build machine file field
  field = x:
    if (x == null || x == [ ] || x == "") then "-"
    else if (builtins.isInt x) then (builtins.toString x)
    else if (builtins.isList x) then (builtins.concatStringsSep "," x)
    else x;
  mkBuildMachine =
    { uri ? null
    , systems ? null
    , sshKey ? null
    , maxJobs ? null
    , speedFactor ? null
    , supportedFeatures ? null
    , mandatoryFeatures ? null
    , publicHostKey ? null
    }: ''
      ${field uri} ${field systems} ${field sshKey} ${field maxJobs} ${field speedFactor} ${field supportedFeatures} ${field mandatoryFeatures} ${field publicHostKey}
    '';
  mkBuildMachinesFile = x: builtins.toFile "machines" (
    builtins.concatStringsSep "\n" (
      map (mkBuildMachine) x
    )
  );
in
{
  security.acme.certs = {
    "hydra.dechnik.net" = {
      group = "nginx";
    };
  };
  # https://github.com/NixOS/nix/issues/5039
  nix.extraOptions = ''
    allowed-uris = https:// http://
  '';
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.dechnik.net";
      notificationSender = "hydra@dechnik.net";
      listenHost = "localhost";
      smtpHost = "localhost";
      useSubstitutes = true;
      extraConfig = /* xml */ ''
        max_unsupported_time = 30
        <githubstatus>
          jobs = .*
          useShortContext = true
        </githubstatus>
      '';
      buildMachinesFiles = [
        (mkBuildMachinesFile [
          {
            uri = "ssh://nix-ssh@dziad";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 12;
            speedFactor = 150;
            supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
          }
          {
            uri = "ssh://nix-ssh@tolek.oracle";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 4;
            speedFactor = 100;
            supportedFeatures = [ "kvm" ];
          }
          {
            uri = "ssh://nix-ssh@ldlat";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 6;
            speedFactor = 100;
            supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark"];
          }
          {
            uri = "localhost";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            maxJobs = 8;
            speedFactor = 50;
            supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
          }
        ])
      ];
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
      sopsFile = ../secrets.yaml;
      owner = hydraUser;
      group = hydraGroup;
      mode = "0440";
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/hydra" ];
  };
}

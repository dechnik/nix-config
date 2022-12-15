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
            uri = "ssh://lukasz@10.10.10.3";
            systems = [ "x86_64-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 12;
            speedFactor = 150;
          }
          {
            uri = "localhost";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            maxJobs = 8;
            speedFactor = 50;
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
          "/".proxyPass =
            "http://localhost:${toString config.services.hydra.port}";
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

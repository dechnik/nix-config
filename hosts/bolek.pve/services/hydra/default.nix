{ pkgs, lib, config, outputs, inputs, ... }:
let
  consul = import ../../../../common/functions/consul.nix { inherit lib; };
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

  release-host-branch = pkgs.callPackage ./lib/release-host-branch.nix {
    sshKeyFile = config.sops.secrets.nix-ssh-key.path;
  };
in
{
  # imports = [
  #   inputs.hydra.nixosModules.hydra
  # ];
  imports = [
    ./machines.nix
  ];

  # https://github.com/NixOS/nix/issues/5039
  nix.extraOptions = ''
    allowed-uris = https:// http://
  '';
  # https://github.com/NixOS/nix/issues/4178#issuecomment-738886808
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";

  services = {
    hydra = {
      enable = true;
      # package = pkgs.inputs.hydra.hydra;
      package = pkgs.inputs.hydra.default.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./hydra-restrict-eval.diff];
      });
      hydraURL = "https://hydra.dechnik.net";
      notificationSender = "monitoring@dechnik.net";
      listenHost = "localhost";
      smtpHost = "localhost";
      useSubstitutes = true;
      extraConfig = /* xml */ ''
        max_unsupported_time = 30
        queue_runner_metrics_address = [::]:9198
        <hydra_notify>
          <prometheus>
            listen_address = 127.0.0.1
            port = 9199
          </prometheus>
        </hydra_notify>
        <runcommand>
          job = nix-config:main:*
          command = ${lib.getExe release-host-branch}
        </runcommand>
      '';
      extraEnv = {
        HYDRA_DISALLOW_UNFREE = "0";
        EMAIL_SENDER_TRANSPORT_port = "25";
      };
    };
    traefik.dynamicConfigOptions.http = {
      services.hydra = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:${toString config.services.hydra.port}"; }];
      };

      routers.hydra = {
        rule = "Host(`hydra.dechnik.net`)";
        service = "hydra";
        entryPoints = [ "web" ];
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

  my.consulServices.hydra = consul.prometheusExporter "hydra" 9199;
  my.consulServices.hydra-queue-runner = consul.prometheusExporter "hydra-queue-runner" 9198;
  environment.persistence = {
    "/persist".directories = [ "/var/lib/hydra" ];
  };
}

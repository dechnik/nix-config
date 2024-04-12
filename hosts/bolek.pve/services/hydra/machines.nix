{ config, pkgs, ... }:
let
  buildMachinesFile = (import ./lib/mk-build-machines-file.nix) [
    {
      uri = "ssh://nix-ssh@dziad";
      systems = [ "x86_64-linux" "i686-linux" ];
      sshKey = config.sops.secrets.nix-ssh-key.path;
      maxJobs = 12;
      speedFactor = 150;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
    }
    {
      uri = "ssh://nix-ssh@tolek.oracle";
      systems = [ "aarch64-linux" ];
      sshKey = config.sops.secrets.nix-ssh-key.path;
      maxJobs = 4;
      speedFactor = 100;
      supportedFeatures = [ "kvm" ];
    }
    {
      uri = "ssh://nix-ssh@ldlat";
      systems = [ "x86_64-linux" "i686-linux" ];
      sshKey = config.sops.secrets.nix-ssh-key.path;
      maxJobs = 6;
      speedFactor = 100;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
    }
    {
      uri = "localhost";
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];
      maxJobs = 6;
      speedFactor = 50;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
    }
  ];
in {
  services.hydra.buildMachinesFiles = [ "/etc/nix/hydra-machines" ];


  systemd = {
    timers.builder-pinger = {
      description = "Build machine pinger timer";
      partOf = [ "builder-pinger.service" ];
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnBootSec = "0";
        OnUnitActiveSec = "30s";
      };
    };
    services.builder-pinger = {
      description = "Build machine pinger";
      enable = true;
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };
      path = [
        config.nix.package
        config.programs.ssh.package
        pkgs.diffutils
        pkgs.coreutils
      ];
      script = /* bash */ ''
        set -euo pipefail

        final_file="/etc/nix/hydra-machines"
        temp_file="$(mktemp)"

        check_host() {
          line="$1"
          host="$(echo "$line" | cut -d ' ' -f1)"
          key="$(echo "$line" | cut -d ' ' -f3)"

          if [ "$key" == "-" ]; then
              args=""
          else
              args="ssh-key=$key"
          fi
          if [ "$host" == "localhost" ]; then
              host="local"
          fi

          if timeout 5 nix store ping  --store "$host?$args"; then
              echo "$line" >> $temp_file
          fi
        }

        while read -r host_line; do
          check_host "$host_line" &
        done < "${buildMachinesFile}"

        wait

        touch "$final_file"
        if ! diff <(sort "$temp_file") <(sort "$final_file"); then
          mv "$temp_file" "$final_file"
          chmod 755 "$final_file"
          touch "$final_file" # So that hydra-queue-runner refreshes
        fi
      '';
    };
  };
}

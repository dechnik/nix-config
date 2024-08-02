{
  pkgs,
  config,
  lib,
  ...
}:
let
  restic = import ../../../common/functions/restic.nix { inherit config lib pkgs; };

  paths = [
    "/var/lib/headscale"
    "/var/lib/atticd"
    config.services.postgresqlBackup.location
  ];

  cfg = site: {
    secret = "restic-bolek-bolek-token";
    inherit site;
    inherit paths;
  };
in
lib.mkMerge [ (restic.backupJob (cfg "pve")) ]

{ pkgs
, config
, lib
, ...
}:
let
  restic = import ../../../common/functions/restic.nix { inherit config lib pkgs; };

  paths = [
    config.services.postgresqlBackup.location
    "/srv/lldap"
  ];

  cfg = site: {
    secret = "restic-tolek-pve-token";
    inherit site;
    inherit paths;
  };
in
lib.mkMerge [
  (restic.backupJob (cfg "pve"))
]

{ pkgs
, config
, lib
, ...
}:
let
  restic = import ../../../common/functions/restic.nix { inherit config lib pkgs; };

  paths = [
    "/var/lib/gitness"
  ];

  cfg = site: {
    secret = "restic-tola-bolek-token";
    inherit site;
    inherit paths;
  };
in
lib.mkMerge [
  (restic.backupJob (cfg "pve"))
]

{ pkgs
, config
, lib
, ...
}:
let
  restic = import ../../../common/functions/restic.nix { inherit config lib pkgs; };

  paths = [
    "/var/lib/headscale"
  ];

  cfg = site: {
    secret = "restic-bolek-bolek-token";
    inherit site;
    inherit paths;
  };
in
lib.mkMerge [
  (restic.backupJob (cfg "pve"))
]

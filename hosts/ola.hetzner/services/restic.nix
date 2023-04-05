{ pkgs
, config
, lib
, ...
}:
let
  restic = import ../../../common/functions/restic.nix { inherit config lib pkgs; };

  paths = [
    "/srv/mail"
    "/var/lib/radicale"
  ];

  cfg = site: {
    secret = "restic-ola-pve-token";
    inherit site;
    inherit paths;
  };
in
lib.mkMerge [
  (restic.backupJob (cfg "pve"))
]

{ lib
, config
, pkgs
, ...
}:
with lib; let
  commonJob =
    { name
    , repository
    , secret
    , paths
    , owner ? "root"
    ,
    }:
    mkMerge [
      {
        sops.secrets.${secret} = {
          sopsFile = ../secrets.yaml;
          inherit owner;
        };
      }
      {
        services.restic.backups."${name}" = {
          inherit repository;
          inherit paths;

          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--keep-yearly 75"
          ];
          initialize = true;
          passwordFile = config.sops.secrets."${secret}".path;
        };
      }

      (mkIf pkgs.stdenv.isLinux {
        services.restic.backups."${name}".timerConfig = {
          OnCalendar = "hourly";
        };
      })

      # (mkIf pkgs.stdenv.isLinux {

      # })
    ];

  backupJob =
    { name ? config.networking.fqdn
    , site
    , secret
    , paths
    , owner ? "root"
    ,
    }: (commonJob {
      inherit secret;
      inherit paths;
      inherit owner;
      name = site;
      repository = "rest:https://restic.${site}.dechnik.net/${name}";
    });
in
{
  inherit backupJob;
  inherit commonJob;
}

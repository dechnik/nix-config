{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.golink;

in
{
  options.services.golink = {
    enable = mkEnableOption "Enable golink";

    package = mkOption {
      type = types.package;
      description = ''
        golink package to use
      '';
      default = pkgs.golink;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/golink";
      description = "Path to data dir";
    };

    user = mkOption {
      type = types.str;
      default = "golink";
      description = "User account under which golink runs.";
    };

    group = mkOption {
      type = types.str;
      default = "golink";
      description = "Group account under which golink runs.";
    };

    databaseFile = mkOption {
      type = types.path;
      default = "/var/lib/golink/golink.db";
      description = "Path to SQLite database";
    };

    tailscaleAuthKeyFile = mkOption {
      type = types.path;
      description = "Path to file containing the Tailscale Auth Key";
    };

    verbose = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
    users.users."${cfg.user}" = {
      home = cfg.dataDir;
      createHome = true;
      group = "${cfg.group}";
      isSystemUser = true;
      isNormalUser = false;
      description = "user for golink service";
    };
    users.groups."${cfg.group}" = { };

    systemd.services.golink = {
      enable = true;
      script =
        let
          args = [ "--sqlitedb ${cfg.databaseFile}" ] ++ lib.optionals cfg.verbose [ "--verbose" ];
        in
        ''
          ${lib.optionalString (cfg.tailscaleAuthKeyFile != null) ''
            export TS_AUTHKEY="$(head -n1 ${lib.escapeShellArg cfg.tailscaleAuthKeyFile})"
          ''}

          ${cfg.package}/bin/golink ${builtins.concatStringsSep " " args}
        '';
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        RestartSec = "15";
        WorkingDirectory = "${cfg.dataDir}";
      };
    };
  };
}

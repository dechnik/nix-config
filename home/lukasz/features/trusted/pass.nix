{
  config,
  pkgs,
  lib,
  ...
}:
{

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
    };
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-otp
      exts.pass-import
    ]);
  };

  services.pass-secret-service = {
    enable = true;
    storePath = "${config.home.homeDirectory}/.local/share/password-store";
    extraArgs = [ "-e${config.programs.password-store.package}/bin/pass" ];
  };

  # Ensure the password store things are in the systemd session
  systemd.user.sessionVariables = config.programs.password-store.settings;

  home.persistence = {
    "/persist/home/lukasz".directories = [ ".local/share/password-store" ];
  };

  # systemd.user.services.password-store-sync = {
  #   Unit = {
  #     Description = "Password store sync";
  #   };

  #   Service = {
  #     CPUSchedulingPolicy = "idle";
  #     IOSchedulingClass = "idle";
  #     Environment =
  #       let
  #         makeEnvironmentPairs =
  #           lib.mapAttrsToList (key: value: "${key}=${builtins.toJSON value}");
  #       in
  #         makeEnvironmentPairs config.programs.password-store.settings;
  #     ExecStart = toString (pkgs.writeShellScript "password-store-sync" ''
  #       ${config.programs.password-store.package}/bin/pass git pull --rebase && \
  #       ${config.programs.password-store.package}/bin/pass git push
  #     '');
  #   };
  # };

  # systemd.user.timers.password-store-sync = {
  #   Unit = {
  #     Description = "Password store periodic sync";
  #   };

  #   Timer = {
  #     Unit = "password-store-sync.service";
  #     OnCalendar = "*:0/10";
  #     Persistent = true;
  #   };

  #   Install = {
  #     WantedBy = [ "timers.target" ];
  #   };
  # };
}

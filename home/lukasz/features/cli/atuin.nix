{config,...}:
{
  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = false;
      sync_address = "https://atuin.dechnik.net";
      show_help = false;
      filter_mode_shell_up_key_binding = "session";
      style = "compact";
      inline_height = 16;
      keymap_mode = "auto";
    };
  };
  systemd.user.timers.atuin-sync = {
    Unit.Description = "Atuin auto sync";
    Timer.OnUnitActiveSec = "1h";
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.atuin-sync = {
    Unit.Description = "Atuin auto sync";

    Service = {
      Type = "oneshot";
      ExecStart = "${config.programs.atuin.package}/bin/atuin sync";
      IOSchedulingClass = "idle";
    };
  };
}

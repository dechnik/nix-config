{ pkgs, lib, config, ... }:
let
  pass = "${config.programs.password-store.package}/bin/pass";
in
{
  home.packages = with pkgs; [ vdirsyncer ];

  home.persistence = {
    "/persist/home/lukasz".directories =
      [ ".local/share/vdirsyncer" ];
  };
  home.activation = {
    vdir-config = ''
      mkdir -p "$HOME/.config/vdirsyncer"
      ln -sf "/run/vdir-config" "$HOME/.config/vdirsyncer/config"
    '';
  };

  systemd.user.services.vdirsyncer = {
    Unit = { Description = "vdirsyncer synchronization"; };
    Service =
      let gpgCmds = import ../trusted/keyring.nix { inherit pkgs; };
      in
      {
        Type = "oneshot";
        ExecCondition = ''
          /bin/sh -c "${gpgCmds.isUnlocked}"
        '';
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
      };
  };
  systemd.user.timers.vdirsyncer = {
    Unit = { Description = "Automatic vdirsyncer synchronization"; };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "5m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}

{ pkgs, lib, config, ... }:
let
  pass = "${config.programs.password-store.package}/bin/pass";
in
{
  home.packages = with pkgs; [ vdirsyncer ];

  xdg.configFile."vdirsyncer/config".text = ''
    [general]
    status_path = "~/.local/share/vdirsyncer/status"

    [pair contacts]
    a = "contacts_local"
    b = "contacts_remote"
    collections = ["from a", "from b"]
    conflict_resolution = "b wins"

    [storage contacts_local]
    type = "filesystem"
    path = "~/Documents/Contacts"
    fileext = ".vcf"

    [storage contacts_remote]
    type = "carddav"
    url = "https://dav.dechnik.net"
    username = "lukasz@dechnik.net"
    password.fetch = ["shell", "${pass} mail.dechnik.net/lukasz@dechnik.net | ${pkgs.coreutils}/bin/head -n1"]

    [pair calendars]
    a = "calendars_local"
    b = "calendars_remote"
    collections = ["from a", "from b"]
    metadata = ["color"]
    conflict_resolution = "b wins"

    [storage calendars_local]
    type = "filesystem"
    path = "~/Documents/Calendars"
    fileext = ".ics"

    [storage calendars_remote]
    type = "caldav"
    url = "https://dav.dechnik.net"
    username = "lukasz@dechnik.net"
    password.fetch = ["shell", "${pass} mail.dechnik.net/lukasz@dechnik.net | ${pkgs.coreutils}/bin/head -n1"]
  '';

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

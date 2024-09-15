{ config, ... }:
let
  site = builtins.replaceStrings [ ".dechnik.net" ] [ "" ] config.networking.domain;
in
{
  environment.persistence = {
    "/persist".directories = [ "/var/lib/samba" ];
  };

  services.samba = {
    # REMIND: `smbpasswd -a`

    enable = true;

    settings = {
      global = {
        "netbios name" = "${config.networking.hostName}-${site}";
        "mdns name" = "mdns";
        "server string" = "Samba on ${config.networking.hostName}.${site}";
        # This would preferrably be SMB3, but iOS Files.app does not
        # support authing/handshaking over SMB3.
        "min protocol" = "SMB2";
        "encrypt passwords" = "yes";
        # Windows discovery
        "wins support" = "yes";
        "local master" = "yes";
        "preferred master" = "yes";
        "workgroup" = "WORKGROUP";
        "vfs objects" = "catia fruit streams_xattr";
        # macOS optimalisation
        "fruit:aapl" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacPro7,1";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:advertise_fullsync" = "true";
        "map to guest" = "bad user";
      };
    };
  };
}

{ ... }:
let
  guestShare = path: {
    inherit path;
    browsable = "yes";
    public = "yes";
    "read only" = "yes";
  };
in
{
  services.samba = {
    settings = {
      storage = {
        path = "/storage/storage";
        browsable = "yes";
        public = "no";
        writeable = "yes";
        "valid users" = "lukasz";
        "force user" = "storage";
        "force group" = "storage";
        "create mask" = "0755";
        "directory mask" = "0775";
      };
    };
  };
}

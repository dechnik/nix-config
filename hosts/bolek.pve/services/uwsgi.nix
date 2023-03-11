{ lib, ... }:
{
  services = {
    uwsgi = {
      enable = true;
      user = "nginx";
      group = "nginx";
      plugins = [ "cgi" ];
      instance = {
        type = "emperor";
        vassals = lib.mkBefore { };
      };
    };
  };
}

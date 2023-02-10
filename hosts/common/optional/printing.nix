{ pkgs
, ...
}: {
  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
  };
  environment.persistence = {
    "/persist".directories = [ "/etc/cups/ppd" ];
    # "/persist".files = [
    #   "/etc/cups/printers.conf"
    # ];
  };
}

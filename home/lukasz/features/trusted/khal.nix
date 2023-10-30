{ pkgs, ... }: {
  # TODO enable when https://github.com/NixOS/nixpkgs/issues/263504 resolved
  # home.packages = with pkgs; [ khal ];
  xdg.configFile."khal/config".text = ''
    [calendars]

    [[personal]]
    path = ~/Documents/Calendars/Personal
    color = dark green

    [[dechnik]]
    path = ~/Documents/Calendars/Dechnik
    color = dark red

    [[work]]
    path = ~/Documents/Calendars/Work
    color = dark blue

    [locale]
    timeformat = %H:%M
    dateformat = %d-%m-%Y
  '';
  home.persistence = {
    "/persist/home/lukasz" = {
      directories = [
        ".local/share/khal"
      ];
    };
  };
}

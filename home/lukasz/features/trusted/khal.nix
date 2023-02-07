{ pkgs, ... }: {
  home.packages = with pkgs; [ khal ];
  xdg.configFile."khal/config".text = ''
    [calendars]

    [[calendars]]
    path = ~/Documents/Calendars/*
    type = discover

    [locale]
    timeformat = %H:%M
    dateformat = %d/%m/%Y
  '';
}

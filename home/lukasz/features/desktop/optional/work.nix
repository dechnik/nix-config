{ pkgs
, lib
, ...
}:
{
  home.packages = with pkgs; [
    remmina
    slack
  ];
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  home.persistence = {
    "/persist/home/lukasz" = {
      directories = [
        ".local/share/remmina"
        ".config/Slack"
      ];
    };
  };
}

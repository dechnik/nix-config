{ pkgs, lib, ... }: {
  home.packages = [ pkgs.lutris ];

  home.persistence = {
    "/persist/games/lukasz" = {
      allowOther = true;
      directories = [ "Games/Lutris" ".config/lutris" ".local/share/lutris" ];
    };
  };
}

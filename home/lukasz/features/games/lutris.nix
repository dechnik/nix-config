{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    (lutris.override {
       extraPkgs = pkgs: [
         pkgs.libnghttp2
         # List package dependencies here
       ];
    })
  ];

  home.persistence = {
    "/persist/games/lukasz" = {
      allowOther = true;
      directories = [ "Games/Lutris" ".config/lutris" ".local/share/lutris" ];
    };
  };
}

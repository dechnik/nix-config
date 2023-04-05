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
    "/persist/home/lukasz" = {
      allowOther = true;
      directories = [
        "Games/Lutris"
        "Games/battlenet"
        "Games/epic-games-store"
        ".config/lutris"
        ".local/share/lutris"
      ];
    };
  };
}

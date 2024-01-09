{ pkgs, ... }: {
  home.packages = with pkgs; [
    (lutris.override {
      extraPkgs = pkgs: [
        pkgs.libnghttp2
        # List package dependencies here
      ];
    })
  ];

  # home.persistence = {
  #   "/persist/home/lukasz" = {
  #     allowOther = true;
  #     directories = [
  #       {
  #         # Use symlink, as games may be IO-heavy
  #         directory = "Games/Lutris";
  #         method = "symlink";
  #       }
  #       {
  #         # Use symlink, as games may be IO-heavy
  #         directory = "Games/epic-games-store";
  #         method = "symlink";
  #       }
  #       {
  #         # Use symlink, as games may be IO-heavy
  #         directory = "Games/battlenet";
  #         method = "symlink";
  #       }
  #       ".config/lutris"
  #       ".local/share/lutris"
  #     ];
  #   };
  # };
}

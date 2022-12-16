{ pkgs ? null }: {
  shellcolord = pkgs.callPackage ./shellcolord { };
  lyrics = pkgs.callPackage ./lyrics { };
  primary-xwayland = pkgs.callPackage ./primary-xwayland { };
  wl-mirror-pick = pkgs.callPackage ./wl-mirror-pick { };
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome { };
}

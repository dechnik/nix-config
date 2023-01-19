{ pkgs ? null }: {
  shellcolord = pkgs.callPackage ./shellcolord { };
  lyrics = pkgs.callPackage ./lyrics { };
  pass-wofi = pkgs.callPackage ./pass-wofi { };
  primary-xwayland = pkgs.callPackage ./primary-xwayland { };
  wl-mirror-pick = pkgs.callPackage ./wl-mirror-pick { };
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome { };
  xpo = pkgs.callPackage ./xpo { };
}

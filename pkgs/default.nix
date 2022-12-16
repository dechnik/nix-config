{ pkgs ? null }: {
  shellcolord = pkgs.callPackage ./shellcolord { };
  lyrics = pkgs.callPackage ./lyrics { };
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome { };
}

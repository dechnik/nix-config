{ pkgs ? null }: {
  shellcolord = pkgs.callPackage ./shellcolord { };
  lyrics = pkgs.callPackage ./lyrics { };
}

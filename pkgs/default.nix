{ pkgs ? null }: rec {
  shellcolord = pkgs.callPackage ./shellcolord { };
  lyrics = pkgs.python3Packages.callPackage ./lyrics { };
  pass-wofi = pkgs.callPackage ./pass-wofi { };
  primary-xwayland = pkgs.callPackage ./primary-xwayland { };
  wl-mirror-pick = pkgs.callPackage ./wl-mirror-pick { };
  xpo = pkgs.callPackage ./xpo { };
  spiceto = pkgs.callPackage ./spiceto { };
  cyrus-sasl-xoauth2 = pkgs.callPackage ./cyrus-sasl-xoauth2 { };
  oauth2ms = pkgs.callPackage ./oauth2ms { };
  golink = pkgs.callPackage ./golink { };
  emacsql-sqlite = pkgs.callPackage ./emacsql-sqlite { };
  sessionx = pkgs.callPackage ./sessionx { };
  tailscale-tools = pkgs.callPackage ./tailscale-tools { };
  # cody = pkgs.callPackage ./cody { };
}

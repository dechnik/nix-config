{ lib
, pkgs
, stdenv
, fetchFromGitHub
, pkg-config
, automake
, autoconf
, libtool
, cyrus_sasl
}:

with lib;

stdenv.mkDerivation {
  pname = "cyrus-sasl-xoauth2";
  version = "master";

  src = pkgs.fetchFromGitHub {
    owner = "moriyoshi";
    repo = "cyrus-sasl-xoauth2";
    rev = "master";
    sha256 = "sha256-OlmHuME9idC0fWMzT4kY+YQ43GGch53snDq3w5v/cgk=";
  };

  nativeBuildInputs = [pkg-config automake autoconf libtool];
  propagatedBuildInputs = [cyrus_sasl];

  buildPhase = ''
    ./autogen.sh
    ./configure
  '';

  installPhase = ''
    make DESTDIR="$out" install
  '';

  meta = {
    homepage = "https://github.com/moriyoshi/cyrus-sasl-xoauth2";
    description = "XOAUTH2 mechanism plugin for cyrus-sasl";
    platforms = platforms.all;
  };
}

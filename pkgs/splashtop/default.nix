{ lib
, stdenv
, dpkg
, fetchurl
}:
stdenv.mkDerivation rec {
  pname = "splashtop-business";
  version = "3.5.2.0";
  src = fetchurl {
    url = "https://download.splashtop.com/linuxclient/splashtop-business_Ubuntu_v3.5.2.0_amd64.tar.gz";
    hash = "sha256-WI5lhLysOp74kGo+wfkotE3q7E8JkF5IypG+Bh8rrSg=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontWrapGApps = true;

  unpackPhase = ''
    tar zxf $src
    ar -x splashtop-business_Ubuntu_amd64.deb
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir $out
    cp -R usr opt "$out"
    mkdir $out/bin
    ln -s $out/opt/splashtop-business/splashtop-business $out/bin/
  '';

  meta = with lib; {
    homepage = "https://www.splashtop.com/products/business-access";
    downloadPage = "https://support-splashtopbusiness.splashtop.com/hc/en-us/articles/4404715685147";
    description = "Remotely access your desktop from any device from anywhere!";
    license = licenses.unlicense;
    platforms = [
      "x86_64-linux"
    ];
  };
}
#  new Debian package, version 2.0.
#  size 4776216 bytes: control archive=1716 bytes.
#      834 bytes,    11 lines      control
#      736 bytes,     9 lines      md5sums
#     1799 bytes,    51 lines   *  postinst             #!/bin/sh
#      155 bytes,     7 lines   *  postrm               #!/bin/sh
#      262 bytes,    19 lines   *  preinst              #!/bin/sh
#      274 bytes,    19 lines   *  prerm                #!/bin/sh
#  Package: splashtop-business
#  Version: 3.5.2.0
#  Architecture: amd64
#  Maintainer: Splashtop Inc. <build@splashtop.com>
#  Installed-Size: 23043
#  Depends: curl (>= 7.47.0), libc6 (>= 2.14), libgcc1 (>= 1:3.0), bash-completion, libkeyutils1 (>= 1.5.6), libqt5core5a (>= 5.5.0), libqt5gui5 (>= 5.0.2) | libqt5gui5-gles (>= 5.0.2), libqt5network5 (>= 5.0.2), libqt5widgets5 (>= 5.4.0), libstdc++6 (>= 5.2), libxcb-keysyms1 (>= 0.4.0), libxcb-randr0 (>= 1.3), libxcb-shm0, libxcb-util1 (>= 0.4.0), libxcb-xfixes0, libxcb-xtest0, libxcb1, libpulse0, uuid
#  Recommends: libavcodec-ffmpeg56 (>= 7:2.4) | libavcodec-ffmpeg-extra56 (>= 7:2.4) | libavcodec-extra (>= 7:2.4), libavutil-ffmpeg54 (>= 7:2.4) | libavutil56 (>= 7:2.4)
#  Section: misc
#  Priority: optional
#  Description: Splashtop Business
#   Remotely access your desktop from any device from anywhere!

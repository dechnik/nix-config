{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  wrapGAppsHook,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  curl,
  dbus,
  expat,
  ffmpeg,
  fontconfig,
  freetype,
  glib,
  glibc,
  gtk3,
  gtk4,
  libcanberra,
  liberation_ttf,
  libexif,
  libglvnd,
  libkrb5,
  libnotify,
  libpulseaudio,
  libu2f-host,
  libva,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  qt6,
  speechd,
  udev,
  _7zz,
  vaapiVdpau,
  vulkan-loader,
  wayland,
  wget,
  xdg-utils,
  xfce,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "splashtop-business";
  version = "3.5.2.0";
  src = fetchurl {
    url = "https://download.splashtop.com/linuxclient/splashtop-business_Ubuntu_v3.6.0.0_amd64.tar.gz";
    hash = "sha256-pKAWrDQJMX3Bznd9RBje3TazPvml0jLfGDjg55dQgco=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    curl
    dbus
    expat
    ffmpeg
    fontconfig
    freetype
    glib
    glibc
    gtk3
    gtk4
    libcanberra
    liberation_ttf
    libexif
    libglvnd
    libkrb5
    libnotify
    libpulseaudio
    libu2f-host
    libva
    libxkbcommon
    mesa
    nspr
    nss
    qt6.qtbase
    pango
    pciutils
    pipewire
    speechd
    udev
    _7zz
    vaapiVdpau
    vulkan-loader
    wayland
    wget
    xdg-utils
    xfce.exo
    xorg.libxcb
    xorg.libX11
    xorg.libXcursor
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libXxf86vm
  ];

  unpackPhase = ''
    tar zxf $src
    ar -x splashtop-business_Ubuntu_amd64.deb
    tar xf data.tar.xz
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -vr opt $out
    cp -vr usr/* $out
    mkdir $out/bin
    ln -s $out/opt/splashtop-business/splashtop-business $out/bin/splashtop-business
    substituteInPlace $out/share/applications/splashtop-business.desktop \
      --replace /usr/bin $out/bin \
      --replace Icon=/usr/share/pixmaps/logo_about_biz.png Icon=$out/share/pixmaps/logo_about_biz.png
    makeWrapper "$out/opt/splashtop-business/splashtop-business" "$out/bin/splashtop-business" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.splashtop.com/products/business-access";
    downloadPage = "https://support-splashtopbusiness.splashtop.com/hc/en-us/articles/4404715685147";
    description = "Remotely access your desktop from any device from anywhere!";
    license = licenses.unlicense;
    platforms = [ "x86_64-linux" ];
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

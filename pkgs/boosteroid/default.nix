{ stdenv,
  makeWrapper,
  autoPatchelfHook,
  numactl,
  libva,
  xorg,
  xz,
  lib,
  systemdLibs,
  libxkbcommon,
  libvdpau,
  alsa-lib,
  fontconfig,
  freetype,
  libGL,
  pcre2,
  dbus,
  wayland-scanner,
  fetchurl,
  dpkg
}:
stdenv.mkDerivation rec {
  pname = "boosteroid";
  version = "1.9.3-beta";
  src = fetchurl {
    curlOpts = "--user-agent 'Mozilla/5.0'";
    url = "https://boosteroid.com/linux/installer/boosteroid-install-x64.deb";
    hash = "sha256-Vb+p3KuHE6m1JLBXNjtLeXAefAOt6LtPD6IE+3x/O84=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];
  buildInputs = [
    xorg.xcbutil
    xorg.libxcb
    numactl
    libva
    libvdpau
    xorg.libXfixes
    xorg.libXi
    systemdLibs
    alsa-lib
    xorg.libX11
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    libxkbcommon
    freetype
    fontconfig
    wayland-scanner
    pcre2
    dbus
    libGL
    xz
  ];
  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x $src .";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -m755 -D opt/BoosteroidGamesS.R.L./bin/Boosteroid $out/bin/Boosteroid
    cp -R usr/share $out/
    cp -R usr/local $out/
    cp -R opt/BoosteroidGamesS.R.L./lib $out/
    substituteInPlace $out/share/applications/Boosteroid.desktop \
      --replace-warn /opt/BoosteroidGamesS.R.L./bin $out/bin \
      --replace-warn Icon=/usr/share/icons/Boosteroid/icon.svg Icon=$out/share/icons/Boosteroid/icon.svg
    wrapProgram "$out/bin/Boosteroid" \
      --set QT_QPA_PLATFORM "xcb"
    runHook postInstall
  '';
}

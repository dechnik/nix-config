{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "emacsql-sqlite";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "magit";
    repo = "emacsql";
    rev = version;
    hash = "sha256-b/QEpWMTyVOdkOEhPNJ0x8ukUy9Gc9gYGjnlh0WU9fY=";
  };

  sourceRoot = "source/sqlite";

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin ${meta.mainProgram}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Custom sqlite for emacsql";
    license = licenses.free;
    mainProgram = "emacsql-sqlite";
  };
}

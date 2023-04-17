{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, which
, wasm-pack
, nodePackages
}:

rustPlatform.buildRustPackage rec {
  pname = "lldap";
  version = "0.5.0";
  revision = "d55d4487ed17211cdde96dbc70cfbaaa4825bc26";

  srcs = [
    (fetchFromGitHub {
      name = pname;
      owner = "lldap";
      repo = pname;
      # rev = "v${version}";
      rev = "${revision}";
      sha256 = "sha256-j5zu5lqGpaxoiTRJVIQrhyHUpIkngIcy/9CsrMmu8Ww=";
    })
    # (fetchTarball {
    #   name = "${pname}-app";
    #   url = "https://github.com/nitnelave/lldap/releases/download/v${version}/lldap-x86_64-v${version}.tar.gz";
    #   sha256 = "1cczmr7pjldhchlkmbkzggr28calakqv8rmsqj7ipv1m1hp7mbig";
    # })
  ];

  sourceRoot = pname;

  cargoSha256 = "sha256-pO0kEVzgfOGn4PBzTrUyVfcelS+W6RfkYURTUXpms2k=";
  # cargoSha256 = lib.fakeSha256;

  nativeBuildInputs = [ pkg-config which wasm-pack nodePackages.rollup ];
  buildInputs = [ openssl ];

  postBuild = ''
    mkdir -p $out/app
    # cp ../${pname}-app/release/x86_64/index.html $out/app
    # cp ../${pname}-app/release/x86_64/main.js $out/app
    # cp -r ../${pname}-app/release/x86_64/pkg $out/app
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}

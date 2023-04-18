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

  src = fetchFromGitHub {
      name = pname;
      owner = "lldap";
      repo = pname;
      # rev = "v${version}";
      rev = "${revision}";
      sha256 = "sha256-j5zu5lqGpaxoiTRJVIQrhyHUpIkngIcy/9CsrMmu8Ww=";
    };
  # srcs = [
  #   (fetchFromGitHub {
  #     name = pname;
  #     owner = "lldap";
  #     repo = pname;
  #     # rev = "v${version}";
  #     rev = "${revision}";
  #     sha256 = "sha256-j5zu5lqGpaxoiTRJVIQrhyHUpIkngIcy/9CsrMmu8Ww=";
  #   })
  #   # (fetchTarball {
  #   #   name = "${pname}-app";
  #   #   url = "https://github.com/nitnelave/lldap/releases/download/v${version}/lldap-x86_64-v${version}.tar.gz";
  #   #   sha256 = "1cczmr7pjldhchlkmbkzggr28calakqv8rmsqj7ipv1m1hp7mbig";
  #   # })
  # ];

  sourceRoot = pname;
  cargoLock = {
    lockFile = "${src.out}/Cargo.lock";
    outputHashes = {
      "lber-0.4.1" = "sha256-2rGTpg8puIAXggX9rEbXPdirfetNOHWfFc80xqzPMT4=";
      "opaque-ke-0.6.1" = "sha256-99gaDv7eIcYChmvOKQ4yXuaGVzo2Q6BcgSQOzsLF+fM=";
      "yew_form-0.1.8" = "sha256-1n9C7NiFfTjbmc9B5bDEnz7ZpYJo9ZT8/dioRXJ65hc=";
    };
  };

  cargoSha256 = "sha256-pO0kEVzgfOGn4PBzTrUyVfcelS+W6RfkYURTUXpms2k=";
  # cargoSha256 = lib.fakeSha256;

  nativeBuildInputs = [ pkg-config which wasm-pack nodePackages.rollup ];
  buildInputs = [ openssl ];
  checkType = "debug";

  postBuild = ''
    # ./app/build.sh
    mkdir -p $out/app
    # cp ../${pname}-app/release/x86_64/index.html $out/app
    # cp ../${pname}-app/release/x86_64/main.js $out/app
    # cp -r ../${pname}-app/release/x86_64/pkg $out/app
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}

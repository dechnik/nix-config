{ lib
, pkgs
, buildEnv
, makeWrapper
, isync
, cyrus_sasl
, inputs
}:

with lib;
buildEnv {
  name = "isync-oauth2";
  paths = [isync];
  pathsToLink = ["/bin"];
  nativeBuildInputs = [makeWrapper];
  postBuild = ''
        wrapProgram "$out/bin/mbsync" \
          --prefix SASL_PATH : "${cyrus_sasl.out.outPath}/lib/sasl2:${inputs.cyrus-sasl-xoauth2}/usr/lib/sasl2"
      '';
  meta = {
    platforms = platforms.all;
  };
}

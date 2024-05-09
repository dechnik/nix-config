{ tmuxPlugins,
  fetchFromGitHub,
  makeWrapper,
  lib,
  zoxide,
  fzf,
  gnugrep,
  gnused,
  coreutils
}:
tmuxPlugins.mkTmuxPlugin {
  pluginName = "sessionx";
  version = "20240427";

  src = fetchFromGitHub {
    owner = "omerxx";
    repo = "tmux-sessionx";
    rev = "ac9b0ec219c2e36ce6beb3f900ef852ba8888095";
    hash = "sha256-TO5OG7lqcN2sKRtdF7DgFeZ2wx9O1FVh1MSp+6EoYxc=";
  };
  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace sessionx.tmux \
      --replace "\$CURRENT_DIR/scripts/sessionx.sh" "$out/share/tmux-plugins/sessionx/scripts/sessionx.sh"
    substituteInPlace scripts/sessionx.sh \
      --replace "/tmux-sessionx/scripts/preview.sh" "$out/share/tmux-plugins/sessionx/scripts/preview.sh"
    substituteInPlace scripts/sessionx.sh \
      --replace "/tmux-sessionx/scripts/reload_sessions.sh" "$out/share/tmux-plugins/sessionx/scripts/reload_sessions.sh"
  '';

  postInstall = ''
    chmod +x $target/scripts/sessionx.sh
    wrapProgram $target/scripts/sessionx.sh \
      --prefix PATH : ${ lib.makeBinPath [ zoxide fzf gnugrep gnused coreutils ]}
    chmod +x $target/scripts/preview.sh
    wrapProgram $target/scripts/preview.sh \
      --prefix PATH : ${ lib.makeBinPath [ coreutils gnugrep gnused ]}
    chmod +x $target/scripts/reload_sessions.sh
    wrapProgram $target/scripts/reload_sessions.sh \
      --prefix PATH : ${ lib.makeBinPath [ coreutils gnugrep gnused ]}
  '';

  meta = with lib; {
    description = "A fuzzy Tmux session manager with preview capabilities, deleting, renaming and more!";
    homepage = "https://github.com/omerxx/tmux-sessionx";
    platforms = platforms.all;
  };
}

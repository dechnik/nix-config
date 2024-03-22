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
  version = "20240322";
  src = fetchFromGitHub {
    owner = "omerxx";
    repo = "tmux-sessionx";
    rev = "1314fe62784b67df48cfbe39d1ad8eed1b33079e";
    hash = "sha256-X3iEaKmGdpX+wR1E2qsW1ChUfT39oVK2xXD134WtXyk=";
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
      --prefix PATH : ${lib.makeBinPath [ zoxide fzf gnugrep gnused coreutils ]}
    chmod +x $target/scripts/preview.sh
    wrapProgram $target/scripts/preview.sh \
      --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ]}
    chmod +x $target/scripts/reload_sessions.sh
    wrapProgram $target/scripts/reload_sessions.sh \
      --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ]}
  '';
}

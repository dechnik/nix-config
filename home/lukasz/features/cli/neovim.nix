{ inputs, pkgs, ... }:
let
  pythonEnv = pkgs.python3.withPackages (
    ps:
    with ps;
    [
      python-lsp-server
      pyls-isort
      pytest
      black
      nose
      mypy
      pylama
      flake8
      tldextract # required by qute-pass
    ]
    ++ python-lsp-server.optional-dependencies.all
  );
in
{
  home.packages = with pkgs; [
    statix
    editorconfig-checker
    deadnix
    nixd
    pythonEnv
    binutils # native-comp needs 'as', provided by this
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity
    fd # faster projectile indexing
    imagemagick # for image-dired
    zstd # for undo-fu-session/undo-tree compression
    editorconfig-core-c # per-project style config
    alejandra
    shellcheck
    shellharden
    shfmt
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      lua-language-server
      nixd
      nil
      rnix-lsp
      shfmt
      universal-ctags
      ripgrep
      fd
      nix-doc
    ];
    extraPython3Packages =
      py: with py; [
        black
        python-lsp-server
        flake8
      ];
  };
}

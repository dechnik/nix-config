{ inputs, pkgs, ... }:
let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    python-lsp-server
    pyls-isort
    pytest
    black
    nose
    mypy
    pylama
    flake8
    tldextract # required by qute-pass
  ] ++ python-lsp-server.optional-dependencies.all);
in
{
  xdg.desktopEntries."nvim" = {
    name = "NeoVim";
    comment = "Edit text files";
    icon = "nvim";
    exec = "${pkgs.kitty}/bin/kitty -1 -e ${pkgs.neovim}/bin/nvim %F";
    categories = [ "TerminalEmulator" ];
    terminal = false;
    mimeType = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };
  home.packages = with pkgs; [
    neovim
    statix
    editorconfig-checker
    deadnix
    pythonEnv
    binutils # native-comp needs 'as', provided by this
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity
    fd # faster projectile indexing
    imagemagick # for image-dired
    zstd # for undo-fu-session/undo-tree compression
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    editorconfig-core-c # per-project style config
    sqlite
    rnix-lsp
    pythonEnv
    shellcheck
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages_latest.pyright
    nodePackages.write-good
    # nodejs-18_x
    # nodePackages.typescript-language-server
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}

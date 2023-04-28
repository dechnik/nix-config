{ pkgs
, inputs
, config
, ...
}:
let
  c = config.xdg.configHome;
  h = config.home.homeDirectory;
  # my_emacs = pkgs.emacs28NativeComp;
  my_emacs = inputs.emacs-overlay.packages.${pkgs.system}.emacsPgtk.overrideAttrs (_: {
    name = "emacs-unstable";
    version = "28-${inputs.emacs-src.shortRev}";
    src = inputs.emacs-src;
  });
  # my_emacs = inputs.emacs-overlay.packages.${pkgs.system}.emacsPgtk.overrideAttrs (_: {
  #   name = "emacs29";
  #   version = "29.0-${inputs.emacs-src.shortRev}";
  #   src = inputs.emacs-src;
  # });
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    python-lsp-server
    pyls-isort
    pytest
    nose
  ] ++ python-lsp-server.optional-dependencies.all);
in
{
  home = {
    sessionVariables = {
      EDITOR = "emacsclient -create-frame --alternate-editor= --no-wait";
    };
  };
  # home.file.".emacs.d" = {
  #   source = pkgs.fetchFromGitHub {
  #       owner = "doomemacs";
  #       repo = "doomemacs";
  #       rev = "3a348944925914b21739b5e9a841d92c1322089b";
  #       sha256 = "6z/TM+vbBXVRrI1PjsDp7+Fve1LJ5ZMvXYf7iZRKb0U=";
  #     };
  # };
  # xdg.configFile = {
  #   "doom" = {
  #     source = ./config;
  #     # onChange = ''
  #     #     export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
  #     #     if [ -d "${h}/.emacs.d" ]; then
  #     #       ${h}/.emacs.d/bin/doom sync
  #     #     fi
  #     #   '';
  #     recursive = true;
  #   };
  # };
  home.packages = with pkgs; let
    emacs-client = makeDesktopItem {
      name = "emacs-client";
      desktopName = "Emacs Client";
      genericName = "Text Editor";
      keywords = [ "Text" "Editor" ];
      comment = "Edit text";
      type = "Application";
      terminal = false;
      startupWMClass = "Emacs";
      exec = "${emacs-overlay}/bin/emacsclient -create-frame --alternate-editor= --no-wait %F";
      # Exec=sh -c "if [ -n \\"\\$*\\" ]; then exec emacsclient --alternate-editor= --display=\\"\\$DISPLAY\\" \\"\\$@\\"; else exec emacsclient --alternate-editor= --create-frame; fi" placeholder %F
      icon = "emacs";
      categories = [ "Development" "TextEditor" ];
      mimeTypes = [
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
  in
  [
    ## Emacs itself
    binutils # native-comp needs 'as', provided by this

    ## Doom dependencies
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity

    ## Optional dependencies
    fd # faster projectile indexing
    imagemagick # for image-dired
    # pinentry_emacs # in-emacs gnupg prompts
    zstd # for undo-fu-session/undo-tree compression

    zotero

    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    rnix-lsp
    pythonEnv
    shellcheck

    # Node
    nodejs-16_x
    # emacs-client
  ];
  services.emacs = {
    enable = true;
    package = my_emacs;
    client.enable = true;
  };

  systemd.user.services.emacs-kill-fisrt-frame = {
    Unit = {
      Description = "emacsclient kill first framer";
      After = "emacs.service";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.runtimeShell} -l -c '${my_emacs}/bin/emacsclient -c --eval \"(delete-frame)\"'";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 6";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
  systemd.user.services.emacs.Service.Environment = "PATH=${config.programs.password-store.package}/bin:$PATH";
  programs.emacs = {
    enable = true;
    package = my_emacs;
    overrides = final: _prev: {
      nix-theme = final.callPackage ./theme.nix { inherit config; };
    };
    extraPackages = epkgs: (with epkgs; [
      nix-theme
      vterm
      all-the-icons-ivy
    ]);
  };
  home.sessionPath = [
    (h + "/.emacs.d/bin")
  ];
  home.sessionVariables = {
    DOOMDIR = "${c}/doom";
  };

  home.persistence = {
    "/persist/home/lukasz".directories = [
      ".emacs.d"
      ".config/doom"
    ];
  };

  home.activation = {
    installDoomEmacs = ''
      export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
      if [ ! -d "${h}/.emacs.d" ]; then
        git clone --depth=1 https://github.com/doomemacs/doomemacs.git ${h}/.emacs.d
      fi
    '';
  };
}

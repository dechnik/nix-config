{ pkgs
, inputs
, config
, ...
}:
let
  c = config.xdg.configHome;
  h = config.home.homeDirectory;
  emacsmail = pkgs.writeShellScriptBin "emacsmail" ''
    emacsclient -create-frame --alternate-editor= --no-wait --eval "(progn (x-focus-frame nil) (mu4e-compose-from-mailto \"$1\" t))"
  '';
  # my_emacs = pkgs.emacs28NativeComp;
  my_emacs = inputs.emacs-overlay.packages.${pkgs.system}.emacsPgtk.overrideAttrs (_: {
    name = "emacs-unstable";
    version = "29-${inputs.emacs-src.shortRev}";
    src = inputs.emacs-src;
  });
  my_emacs_with_packages = with pkgs; ((emacsPackagesFor my_emacs).emacsWithPackages (epkgs: [
    epkgs.vterm
    epkgs.all-the-icons-ivy
    epkgs.all-the-icons
  ]));
  # my_emacs = inputs.emacs-overlay.packages.${pkgs.system}.emacsPgtk.overrideAttrs (_: {
  #   name = "emacs29";
  #   version = "29.0-${inputs.emacs-src.shortRev}";
  #   src = inputs.emacs-src;
  # });
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    python-lsp-server
    pyls-isort
    pytest
    black
    nose
    mypy
    tldextract # required by qute-pass
  ] ++ python-lsp-server.optional-dependencies.all);
in
{
  # home = {
  #   sessionVariables = {
  #     EDITOR = "emacsclient -create-frame --alternate-editor= --no-wait";
  #   };
  # };

  xdg = {
    desktopEntries = {
      orgProtocolDesktop = {
        name = "Org-Protocol";
        genericName = "Org-Protocol";
        exec = "${my_emacs_with_packages}/bin/emacsclient -create-frame --alternate-editor= --no-wait %u";
        type = "Application";
        mimeType = [ "x-scheme-handler/org-protocol" ];
        icon = "emacs";
        terminal = false;
      };
      mu4e = {
        name = "Mu4e";
        genericName = "Compose a new message with Mu4e in Emacs";
        comment = "Open mu4e compose window";
        exec = "emacsmail %U";
        icon = "emacs";
        terminal = false;
        categories = [ "Network" "Email" ];
        type = "Application";
        mimeType = [ "x-scheme-handler/mailto" ];
      };
    };
    mimeApps.defaultApplications = {
      "x-scheme-handler/org-protocol" = "orgProtocolDesktop.desktop";
      "x-scheme-handler/mailto" = "mu4e.desktop";
    };
  };
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

    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    emacsql-sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-full
    rnix-lsp
    pythonEnv
    shellcheck

    zotero

    # Node
    nodejs-18_x
    nodePackages.typescript-language-server
    emacsmail
    # emacs-client
  ];
  services.emacs = {
    enable = true;
    package = my_emacs_with_packages;
    client.enable = true;
  };

  systemd.user.services.zotero = {
    Unit = {
      Description = "Zotero headless";
      After = "emacs.service";
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.runtimeShell} -l -c '${pkgs.zotero}/bin/zotero --headless'";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 60";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
  # systemd.user.services.emacs-kill-fisrt-frame = {
  #   Unit = {
  #     Description = "emacsclient kill first framer";
  #     After = "emacs.service";
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.runtimeShell} -l -c '${my_emacs}/bin/emacsclient -c --eval \"(delete-frame)\"'";
  #     ExecStartPre = "${pkgs.coreutils}/bin/sleep 6";
  #   };
  #   Install = { WantedBy = [ "default.target" ]; };
  # };
  # systemd.user.services.emacs = {
  #   Unit = {
  #     Description = "Emacs text editor";
  #     Documentation = "info:emacs man:emacs(1) https://gnu.org/software/emacs/";
  #     X-RestartIfChanged = false;
  #   };
  #   Service = {
  #     Environment = "PATH=${pkgs.libnotify}/bin:PATH=${config.programs.password-store.package}/bin:$PATH";
  #     Type = "forking";
  #     ExecStart = "${pkgs.bash}/bin/bash -l -c '${my_emacs}/bin/emacs --fg-daemon && ${my_emacs}/bin/emacsclient -c --eval \"(delete-frame)\"'";
  #     ExecStop = "${my_emacs}/bin/emacsclient --no-wait --eval (kill-emacs)";
  #     Restart = "always";
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };
  systemd.user.services.emacs.Service.Environment = "PATH=${config.programs.password-store.package}/bin:${pkgs.emacsql-sqlite}/bin:$PATH";
  programs.emacs = {
    enable = true;
    package = my_emacs_with_packages;
    # overrides = final: _prev: {
    #   nix-theme = final.callPackage ./theme.nix { inherit config; };
    # };
    # extraPackages = epkgs: (with epkgs; [
    # ]);
  };
  home.sessionPath = [
    (h + "/.emacs.d/bin")
  ];
  home.sessionVariables = {
    DOOMDIR = "${c}/doom";
    MINEMACSDIR = "${h}/.emacs.d/minemacs";
  };

  home.persistence = {
    "/persist/home/lukasz".directories = [
      ".emacs.d"
      ".config/doom"
    ];
  };
}

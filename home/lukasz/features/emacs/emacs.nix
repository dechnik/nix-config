{
  pkgs,
  config,
  ...
}:
let
  my_emacs = pkgs.emacs29-pgtk;
in
{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/org" = "emacsclient.desktop";
      };
    };
  };
  home.packages = with pkgs; [
    sqlite
    emacsql-sqlite
    shellcheck
    gnumake
    graphviz
    sdcv
    enchant
    (hunspellWithDicts (with hunspellDicts; [ en-us-large ]))
    hunspellDicts.en-us-large
    (aspellWithDicts (
      ds: with ds; [
        en
        en-computers
        en-science
      ]
    ))
  ];
  services.emacs = {
    enable = true;
    package = my_emacs;
    client.enable = true;
  };
  programs.emacs = {
    enable = true;
    package = my_emacs;
    extraPackages =
      epkgs: with epkgs; [
        vterm
        pdf-tools
        all-the-icons-ivy
        all-the-icons
      ];
  };
  systemd.user.services.emacs.Service.Environment = "PATH=${config.programs.password-store.package}/bin:${pkgs.emacsql-sqlite}/bin:$PATH";
}

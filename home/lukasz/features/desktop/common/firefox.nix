{ pkgs, lib, inputs, ... }:

let
  addons = inputs.firefox-addons.packages.${pkgs.system};
in
{
  programs.browserpass.enable = true;
  home.packages = with pkgs; [ tridactyl-native ];
  xdg.configFile."tridactyl/tridactylrc".text = ''
    " Clear the config
    sanitise tridactyllocal tridactylsync
    " Scroll settings
    set smoothscroll true
    " Use default new tab
    set newtab about:newtab
    " Use custom theme
    colourscheme --url https://github.com/jrolfs/gruvbox-material-tridactyl/releases/download/v0.1.1/dark-soft.css gruvbox-material
    set searchurls.sx https://sx.dechnik.net/search?q=
    set searchurls.no https://search.nixos.org/options?query=
    set searchurls.np https://search.nixos.org/packages?query=
    set searchengine sx
    " Move between tabs
    unbind h,l
    bind h tabprev
    bind l tabnext
  '';
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = { enableTridactylNative = true; };
    };
    profiles.lukasz = {
      extensions = with addons; [
        ublock-origin
        bitwarden
        darkreader
        browserpass
        # surfingkeys
        tridactyl
        simple-tab-groups
      ];
      bookmarks = { };
      settings = {
        # Enable DRM
        "media.eme.enabled" = true;
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        # GPU acceleration
        "media.rdd-ffmpeg.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        "media.ffvpx.enabled" = false;
        "media.rdd-process.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        # "browser.startup.homepage" = "about:home";
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "dom.security.https_only_mode" = true;
        # "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
      };

      userChrome = ''
        /* Hide the thin line between the tabs and the main viewport. */
        #navigator-toolbox {
          border-bottom: none !important;
        }
      '';
    };
  };

  home = {
    sessionVariables = {
      BROWSER = "firefox";
    };
    persistence = {
      "/persist/home/lukasz".directories = [ ".mozilla/firefox" ];
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

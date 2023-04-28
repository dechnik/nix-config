{ pkgs, lib, inputs, ... }:

let
  addons = inputs.firefox-addons.packages.${pkgs.system};
  zotero-connector = inputs.firefox-addons.lib.${pkgs.system}.buildFirefoxXpiAddon rec {
    pname = "zotero-connector";
    version = "5.0.107";
    addonId = "zotero@chnm.gmu.edu";
    url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-${version}.xpi";
    sha256 = "RuAhWGvUhkog8SxzKhRwQQwzTQLzBKlHjSsFj9e25e4=";
    meta = with lib; {
      homepage = "https://www.zotero.org";
      description = "Save references to Zotero from your web browser";
      license = licenses.agpl3;
      platforms = platforms.all;
    };
  };
in
{
  programs.browserpass.enable = true;
  home.packages = with pkgs; [ tridactyl-native ];
  home.file.".mozilla/native-messaging-hosts/tridactyl.json" = {
    source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";
  };
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
    bind / fillcmdline find
    bind ? fillcmdline find --reverse
    bind n findnext --search-from-view
    bind N findnext --search-from-view --reverse
    bind gn findselect
    bind gN composite findnext --search-from-view --reverse; findselect
    bind ,<Space> nohlsearch
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
        zotero-connector
      ];
      bookmarks = { };
      settings = {
        # Enable DRM
        "media.eme.enabled" = true;
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.download.always_ask_before_handling_new_types" = true;
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
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action","browserpass_maximbaz_com-browser-action","_15bdb1ce-fa9d-4a00-b859-66c214263ac0_-browser-action","addon_darkreader_org-browser-action","simple-tab-groups_drive4ik-browser-action","zotero_chnm_gmu_edu-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action","browserpass_maximbaz_com-browser-action","_15bdb1ce-fa9d-4a00-b859-66c214263ac0_-browser-action","addon_darkreader_org-browser-action","simple-tab-groups_drive4ik-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","zotero_chnm_gmu_edu-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list","unified-extensions-area"],"currentVersion":19,"newElementCount":4}'';
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

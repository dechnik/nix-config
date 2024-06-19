{ lib, config, pkgs, ... }:

let inherit (config.colorscheme) palette variant;
  browser = ["org.qutebrowser.qutebrowser.desktop"];
  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
  };
  gruvbox-css = builtins.fetchurl {
    name = "gruvbox-all-sites.css";
    url = "https://github.com/alphapapa/solarized-everything-css/raw/master/css/gruvbox/gruvbox-all-sites.css";
    sha256 = "sha256:1l9bsdcf2qdrjb5q6z59q38kinr1f8b10wahb1kf51py24v1mjwz";
  };
in
{
  home = {
    sessionVariables = {
      BROWSER = "qutebrowser";
    };
    persistence = {
      "/persist/home/lukasz".directories = [
        ".config/qutebrowser/greasemonkey"
        ".local/share/qutebrowser"
      ];
    };
  };


  home.activation = {
    qutebrowser-marks = ''
      if [[ -f $HOME/Documents/qutebrowser/quickmarks ]]; then
        rm -rf "$HOME/.config/qutebrowser/quickmarks"
        ln -sf "$HOME/Documents/qutebrowser/quickmarks" "$HOME/.config/qutebrowser/quickmarks"
      fi
      if [[ -d $HOME/Documents/qutebrowser/bookmarks ]]; then
        rm -rf "$HOME/.config/qutebrowser/bookmarks"
        ln -sf "$HOME/Documents/qutebrowser/bookmarks" "$HOME/.config/qutebrowser/bookmarks"
      fi
    '';
    # Install language dictionaries for spellcheck backends
    qutebrowserInstallDicts =
      lib.concatStringsSep "\\\n" (map (lang: ''
            if ! find "$XDG_DATA_HOME/qutebrowser/qtwebengine_dictionaries" -type d -maxdepth 1 -name "${lang}*" 2>/dev/null | grep -q .; then
            ${pkgs.python3}/bin/python ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install ${lang}
            fi
            '') ["en-US" "pl-PL"]);
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;
  # xdg.mimeApps.defaultApplications = {
  #   "text/html" = [ "org.qutebrowser.qutebrowser.desktop" ];
  #   "text/xml" = [ "org.qutebrowser.qutebrowser.desktop" ];
  #   "x-scheme-handler/http" = [ "org.qutebrowser.qutebrowser.desktop" ];
  #   "x-scheme-handler/https" = [ "org.qutebrowser.qutebrowser.desktop" ];
  #   "x-scheme-handler/qute" = [ "org.qutebrowser.qutebrowser.desktop" ];
  # };

  programs.qutebrowser = {
    enable = true;
    package = pkgs.qutebrowser.override {
      enableWideVine = true;
    };
    loadAutoconfig = true;
    searchEngines = {
      DEFAULT = "https://search.brave.com/search?q={}";
      b = "https://search.brave.com/search?q={}";
      nu = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
      nh = "https://home-manager-options.extranix.com/?release=master&query={}";
      gh = "https://github.com/search?type=repositories&q={}";
      yt = "https://www.youtube.com/results?search_query={}";
    };
    keyBindings.normal = {
      # try to fill username / password
      ",p" = "spawn --userscript qute-pass --dmenu-invocation 'wofi --show dmenu'";
      ",m" = "hint links spawn --detach mpv {hint-url}";
    };
    settings = {
      url.start_pages  = [
        "https://search.brave.com"
      ];
      qt.args = [
        "enable-accelerated-video-decode"
        "enable-gpu-rasterization"
        "ignore-gpu-blocklist"
      ];
      qt.highdpi = true;
      confirm_quit = ["downloads"];
      editor.command = ["kitty" "nvim" "{file}" "-c" "normal {line}G{column0}l"];
      # scrolling.smooth =
      #   if pkgs.stdenv.isDarwin
      #   then false
      #   else true;
      downloads.location.directory = "${
        if pkgs.stdenv.isDarwin
        then "/Users/"
        else "/home/"
      }lukasz/Downloads";
      downloads.position = "bottom";
      fileselect.single_file.command = [
        "kitty"
        "--class"
        "yazi,yazi"
        "-1"
        "-e"
        "yazi --chooser-file {}"
      ];
      fileselect.multiple_files.command = [
        "kitty"
        "--class"
        "yazi,yazi"
        "-1"
        "-e"
        "yazi --chooser-file {}"
      ];
      spellcheck.languages = ["en-US" "pl-PL"];
      auto_save.session = true;
      # if input is focused on tab load, allow typing
      input.insert_mode.auto_load = true;
      # exit insert mode if clicking on non editable item
      input.insert_mode.auto_leave = true;
      window.hide_decoration = true;
      tabs.title.format = "{audio}{index}: {current_title}";
      tabs.title.format_pinned = "{audio}{index}P: {current_title}";
      tabs = {
        show = "multiple";
        position = "left";
        indicator.width = 0;
        width = "6%";
      };
      content.pdfjs = true;
      content.autoplay = false;
      content.headers.do_not_track = true;
      content.default_encoding = "utf-8";
      content.javascript.clipboard = "access";
      content.webgl = true;
      content = {
        blocking = {
          enabled = true;
          method = "both";
          adblock.lists = [
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylist/easyprivacy.txt"
            "https://easylist.to/easylist/fanboy-annoyance.txt"
            "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
            "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
            "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt"
            "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"
            "https://www.i-dont-care-about-cookies.eu/abp/"
            "https://raw.githubusercontent.com/Ewpratten/youtube_ad_blocklist/master/blocklist.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext"
            "https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter-online.txt"
          ];
        };
      };
      fonts = {
        default_family = config.fontProfiles.regular.family;
        default_size = "10pt";
        web.family.fixed = config.fontProfiles.monospace.family;
      };
      colors = {
        webpage = {
          preferred_color_scheme = "dark";
          bg = "#ffffff";
        };
        completion = {
          fg = "#${palette.base05}";
          match.fg = "#${palette.base09}";
          even.bg = "#${palette.base00}";
          odd.bg = "#${palette.base00}";
          scrollbar = {
            bg = "#${palette.base00}";
            fg = "#${palette.base05}";
          };
          category = {
            bg = "#${palette.base00}";
            fg = "#${palette.base0D}";
            border = {
              bottom = "#${palette.base00}";
              top = "#${palette.base00}";
            };
          };
          item.selected = {
            bg = "#${palette.base02}";
            fg = "#${palette.base05}";
            match.fg = "#${palette.base05}";
            border = {
              bottom = "#${palette.base02}";
              top = "#${palette.base02}";
            };
          };
        };
        contextmenu = {
          disabled = {
            bg = "#${palette.base01}";
            fg = "#${palette.base04}";
          };
          menu = {
            bg = "#${palette.base00}";
            fg = "#${palette.base05}";
          };
          selected = {
            bg = "#${palette.base02}";
            fg = "#${palette.base05}";
          };
        };
        downloads = {
          bar.bg = "#${palette.base00}";
          error.fg = "#${palette.base08}";
          start = {
            bg = "#${palette.base0D}";
            fg = "#${palette.base00}";
          };
          stop = {
            bg = "#${palette.base0C}";
            fg = "#${palette.base00}";
          };
        };
        hints = {
          bg = "#${palette.base0A}";
          fg = "#${palette.base00}";
          match.fg = "#${palette.base05}";
        };
        keyhint = {
          bg = "#${palette.base00}";
          fg = "#${palette.base05}";
          suffix.fg = "#${palette.base05}";
        };
        messages = {
          error.bg = "#${palette.base08}";
          error.border = "#${palette.base08}";
          error.fg = "#${palette.base00}";
          info.bg = "#${palette.base00}";
          info.border = "#${palette.base00}";
          info.fg = "#${palette.base05}";
          warning.bg = "#${palette.base0E}";
          warning.border = "#${palette.base0E}";
          warning.fg = "#${palette.base00}";
        };
        prompts = {
          bg = "#${palette.base00}";
          fg = "#${palette.base05}";
          border = "#${palette.base00}";
          selected.bg = "#${palette.base02}";
        };
        statusbar = {
          caret.bg = "#${palette.base00}";
          caret.fg = "#${palette.base0D}";
          caret.selection.bg = "#${palette.base00}";
          caret.selection.fg = "#${palette.base0D}";
          command.bg = "#${palette.base01}";
          command.fg = "#${palette.base04}";
          command.private.bg = "#${palette.base01}";
          command.private.fg = "#${palette.base0E}";
          insert.bg = "#${palette.base00}";
          insert.fg = "#${palette.base0C}";
          normal.bg = "#${palette.base00}";
          normal.fg = "#${palette.base05}";
          passthrough.bg = "#${palette.base00}";
          passthrough.fg = "#${palette.base0A}";
          private.bg = "#${palette.base00}";
          private.fg = "#${palette.base0E}";
          progress.bg = "#${palette.base0D}";
          url.error.fg = "#${palette.base08}";
          url.fg = "#${palette.base05}";
          url.hover.fg = "#${palette.base09}";
          url.success.http.fg = "#${palette.base0B}";
          url.success.https.fg = "#${palette.base0B}";
          url.warn.fg = "#${palette.base0E}";
        };
        tabs = {
          bar.bg = "#${palette.base00}";
          even.bg = "#${palette.base00}";
          even.fg = "#${palette.base05}";
          indicator.error = "#${palette.base08}";
          indicator.start = "#${palette.base0D}";
          indicator.stop = "#${palette.base0C}";
          odd.bg = "#${palette.base00}";
          odd.fg = "#${palette.base05}";
          pinned.even.bg = "#${palette.base00}";
          pinned.even.fg = "#${palette.base05}";
          pinned.odd.bg = "#${palette.base00}";
          pinned.odd.fg = "#${palette.base05}";
          pinned.selected.even.bg = "#${palette.base02}";
          pinned.selected.even.fg = "#${palette.base05}";
          pinned.selected.odd.bg = "#${palette.base02}";
          pinned.selected.odd.fg = "#${palette.base05}";
          selected.even.bg = "#${palette.base02}";
          selected.even.fg = "#${palette.base05}";
          selected.odd.bg = "#${palette.base02}";
          selected.odd.fg = "#${palette.base05}";
        };
      };
    };
    extraConfig = ''
      c.tabs.padding = {"bottom": 4, "left": 10, "right": 10, "top": 4}
      config.bind(',gr', 'config-cycle content.user_stylesheets ${gruvbox-css} ""')
    '';
  };
}

{ pkgs
, ...
}:
{
  fonts = {
    fonts = with pkgs; [
      # icon fonts
      material-icons
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      roboto
      overpass
      font-awesome_5
      alegreya
      alegreya-sans
      julia-mono

      emacs-all-the-icons-fonts
      # nerdfonts
      # (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Iosevka" "Ubuntu"];})
    ];
  };
}


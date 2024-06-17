{ pkgs
, ...
}:
{
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-icons
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-code-pro
      nanum-gothic-coding
      roboto
      overpass
      font-awesome_5
      alegreya
      alegreya-sans
      julia-mono
      geist-font

      #remacs-all-the-icons-fonts
      # nerdfonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "GeistMono"];})
    ];
    # enableDefaultFonts = false;

    # # user defined fonts
    # # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # # B&W emojis that would sometimes show instead of some Color emojis
    # fontconfig.defaultFonts = {
    #   serif = ["Noto Serif" "Noto Color Emoji"];
    #   sansSerif = ["Noto Sans" "Noto Color Emoji"];
    #   monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
    #   emoji = ["Noto Color Emoji"];
    # };
  };
}

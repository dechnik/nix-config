{ pkgs, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      # family = "JetBrainsMono Nerd Font";
      # package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      family = "GeistMono Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "GeistMono" ]; };
    };
    regular = {
      family = "Geist Sans";
      package = pkgs.geist-font;
    };
  };
}

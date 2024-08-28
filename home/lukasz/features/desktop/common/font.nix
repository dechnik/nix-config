{ pkgs, ... }:
{
  fontProfiles = {
    enable = true;
    monospace = {
      # family = "JetBrainsMono Nerd Font";
      # package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      name = "GeistMono Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "GeistMono" ]; };
    };
    regular = {
      name = "Geist";
      package = pkgs.geist-font;
    };
  };
}

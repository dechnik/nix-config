{ pkgs, ... }:
{
  fontProfiles = {
    enable = true;
    monospace = {
      # family = "JetBrainsMono Nerd Font";
      # package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      name = "GeistMono Nerd Font";
      package = pkgs.nerd-fonts.geist-mono;
    };
    regular = {
      name = "Geist";
      package = pkgs.geist-font;
    };
  };
}
